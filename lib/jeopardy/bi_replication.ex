defmodule Jeopardy.BIReplication do
  use GenServer
  alias Jeopardy.Repo
  import Ecto.Query
  require Logger

  @moduledoc "Every <config frequency>, replicate our DB updates into Google Cloud Storage"

  def start_link(_), do: start_link()
  def start_link, do: GenServer.start_link(__MODULE__, %{})

  def init(state) do
    # Schedule work to be performed at some point
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Do the work you desire here
    incremental_updates()
    total_db_records()

    # Reschedule once more
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    frequency = Application.fetch_env!(:jeopardy, Jeopardy.BIReplication)[:frequency]
    Process.send_after(self(), :work, frequency)
  end

  def incremental_updates(),
    do:
      ~w(games players clues)
      |> Enum.each(&incremental_updates/1)

  def total_db_records() do
    # Use the cache to see if the number has changed.  Cache is cheap and free.
    {:ok, prev_num_records} = Cachex.get(:stats, "replication:total_db_records")

    num_records =
      from(x in "pg_stat_user_tables", select: sum(x.n_live_tup))
      |> Repo.one()

    Cachex.put(:stats, "replication:total_db_records", num_records)

    Logger.info(
      "[BI_Replication] prev_num_records: #{prev_num_records}, current num_records: #{num_records}"
    )

    # Only upload to GCS if there's been a change.
    # Why? Upload operations cost money when we surpass the free tier threshold.
    if num_records != prev_num_records do
      bucket = Application.fetch_env!(:jeopardy, Jeopardy.BIReplication)[:bucket]
      timestamp = DateTime.to_string(DateTime.utc_now())
      file_name = "db_records_#{timestamp}"
      File.write(file_name, "num_records,replicated_at\n#{num_records},#{timestamp}")
      upload_file(bucket, file_name)
      File.rm(file_name)
    else
      Logger.info("[BI_Replication] no change in num_records. Skipping upload to GCS")
    end
  end

  defp incremental_updates(table) do
    timestamp = DateTime.to_string(DateTime.utc_now())
    file_name = "incremental_#{table}_#{timestamp}"

    module =
      case table do
        "games" -> Jeopardy.Games.Game
        "players" -> Jeopardy.Games.Player
        "clues" -> Jeopardy.Games.Clue
      end

    # NOTE: gigalixir uses Postgres 9.5.19, which does not support COPY(UPDATE ...) syntax
    # As a result we do this in 2 steps, realizing that a record could be updated in between
    # and as a result not be replicated
    #
    # For when the gigalixir postgres version is updated:
    # {:ok, %{num_rows: num_rows}} =
    #   Ecto.Adapters.SQL.query(
    #     Repo,
    #     "COPY (UPDATE #{table} SET replicated_at = (CURRENT_TIMESTAMP AT TIME ZONE 'UTC') WHERE updated_at > replicated_at RETURNING *) to '#{
    #       file_path
    #     }' WITH (FORMAT CSV, HEADER)"
    #   )

    # 1. Get Data
    stream =
      Ecto.Adapters.SQL.stream(
        Repo,
        "COPY (SELECT * FROM #{table} WHERE updated_at > replicated_at OR replicated_at is NULL) to STDOUT WITH (FORMAT CSV, HEADER)"
      )

    # 2. Write csv data to file
    Repo.transaction(fn ->
      stream
      |> Enum.map(& &1.rows)
      |> Stream.into(File.stream!(file_name))
      |> Stream.run()
    end)

    # 3. Update the replicated_at field for all those affected
    {num_rows, _} =
      from(x in module,
        where: x.updated_at > x.replicated_at or is_nil(x.replicated_at)
      )
      |> Repo.update_all(set: [replicated_at: DateTime.utc_now()])

    # 4. Upload the file to GCS if we found any records
    Logger.info("[BI_Replication] found #{num_rows} to replicate in #{table} table")
    bucket = Application.fetch_env!(:jeopardy, Jeopardy.BIReplication)[:bucket]
    if num_rows > 0, do: upload_file(bucket, file_name)

    # 5. Delete the temporary file
    File.rm(file_name)
  end

  defp upload_file(bucket_id, file_path) do
    # Authenticate.
    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/cloud-platform")
    conn = GoogleApi.Storage.V1.Connection.new(token.token)

    # Make the API request.
    {:ok, object} =
      GoogleApi.Storage.V1.Api.Objects.storage_objects_insert_simple(
        conn,
        bucket_id,
        "multipart",
        %{name: Path.basename(file_path)},
        file_path
      )

    # Print the object.
    Logger.info("Uploaded #{object.name} to #{object.selfLink}")
  end
end
