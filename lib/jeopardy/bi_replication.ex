defmodule Jeopardy.BIReplication do
  use GenServer
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

    # Reschedule once more
    schedule_work()
    {:noreply, state}
  end

  # In 1 hour
  # 1 * 60 * 60 * 1000)
  defp schedule_work() do
    frequency = Application.fetch_env!(:jeopardy, Jeopardy.BIReplication)[:frequency]
    Process.send_after(self(), :work, frequency)
  end

  def incremental_updates(),
    do:
      ~w(games players clues)
      |> Enum.each(&incremental_updates/1)

  defp incremental_updates(table) do
    timestamp = DateTime.to_string(DateTime.utc_now())
    file_path = "/tmp/incremental_#{table}_#{timestamp}"

    {:ok, %{num_rows: num_rows}} =
      Ecto.Adapters.SQL.query(
        Jeopardy.Repo,
        "COPY (UPDATE #{table} SET replicated_at = (CURRENT_TIMESTAMP AT TIME ZONE 'UTC') WHERE updated_at > replicated_at RETURNING *) to '#{
          file_path
        }' WITH (FORMAT CSV, HEADER)"
      )

    # don't bother uploading if there was nothing to replicate
    bucket = Application.fetch_env!(:jeopardy, Jeopardy.BIReplication)[:bucket]
    if num_rows > 0, do: upload_file(bucket, file_path)
    File.rm(file_path)
  end

  def full_snapshot(),
    do:
      ~w(games players clues)
      |> Enum.each(&full_snapshot/1)

  defp full_snapshot(table) do
    Ecto.Adapters.SQL.query(
      Jeopardy.Repo,
      "COPY (SELECT * FROM #{table}) to '/tmp/#{table}' WITH (FORMAT CSV, HEADER)"
    )

    upload_file("jeopardy_ryoung_test", "/tmp/#{table}")
    File.rm("/tmp/#{table}")
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
    Logger.warn("Uploaded #{object.name} to #{object.selfLink}")
  end
end
