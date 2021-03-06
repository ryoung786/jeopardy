defmodule Jeopardy.Repo.Migrations.BackfillDraftsFromJarchive do
  use Ecto.Migration
  alias Jeopardy.Repo
  alias Jeopardy.Drafts.Game
  import Ecto.Query
  alias Mix.Tasks.PopulateDraftsFromJarchive, as: Backfill
  require Logger

  def down do
    from(g in Game, where: g.owner_type == "jarchive")
    |> Repo.delete_all()
  end

  def up do
    if Application.get_env(:jeopardy, :env) != :test,
      do: Backfill.get_files([]) |> Backfill.process_files()
  end
end
