defmodule Mix.Tasks.Etl do
  use Mix.Task

  @shortdoc "Replicate DB to BigQuery"
  # @out_path Path.join(:code.priv_dir(:jeopardy), "data")

  def run(_args) do
    Mix.Task.run("app.start")

    Jeopardy.BIReplication.incremental_updates()
  end
end
