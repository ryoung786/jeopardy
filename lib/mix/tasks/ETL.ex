defmodule Mix.Tasks.Etl do
  use Mix.Task

  @shortdoc "Replicate DB to BigQuery"
  # @out_path Path.join(:code.priv_dir(:jeopardy), "data")

  def run(_args) do
    Mix.Task.run("app.start")

    ~w(games players clues)
    |> Enum.each(&incremental_updates/1)
  end

  def incremental_updates(table) do
    timestamp = DateTime.to_string(DateTime.utc_now())
    file_path = "/tmp/incremental_#{table}_#{timestamp}"

    {:ok, %{num_rows: num_rows}} =
      Ecto.Adapters.SQL.query(
        Jeopardy.Repo,
        "COPY (UPDATE #{table} SET replicated_at = now() WHERE updated_at > replicated_at RETURNING *) to '#{
          file_path
        }' WITH (FORMAT CSV, HEADER)"
      )

    # don't bother uploading if there was nothing to replicate
    if num_rows > 0, do: upload_file("jeopardy_ryoung_test", file_path)
    File.rm(file_path)
  end

  def full_snapshot(table) do
    Ecto.Adapters.SQL.query(
      Jeopardy.Repo,
      "COPY (SELECT * FROM #{table}) to '/tmp/#{table}' WITH (FORMAT CSV, HEADER)"
    )

    upload_file("jeopardy_ryoung_test", "/tmp/#{table}")
    File.rm("/tmp/#{table}")
  end

  def upload_file(bucket_id, file_path) do
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
    IO.puts("Uploaded #{object.name} to #{object.selfLink}")
  end
end
