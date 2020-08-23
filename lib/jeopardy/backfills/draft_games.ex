defmodule Jeopardy.Backfills.DraftGames do
  use GenServer
  alias Mix.Tasks.PopulateDraftsFromJarchive, as: Backfill
  alias Jeopardy.Drafts.Game
  alias Jeopardy.Repo
  import Ecto.Query
  require Logger

  def start_link(_), do: start_link()
  def start_link, do: GenServer.start_link(__MODULE__, %{})

  def init(state) do
    Logger.warn("[xxx] beginning backfill")
    count = from(g in Game, where: g.owner_type == "jarchive") |> Repo.aggregate(:count)

    if count < 6000,
      do: Backfill.get_files([]) |> Backfill.process_files(),
      else: Logger.warn("[xxx] backfill already populated")

    Logger.warn("[xxx] finished backfill")
    {:ok, state}
  end
end
