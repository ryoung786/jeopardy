defmodule Jeopardy.FSM.PreJeopardy.SelectingTrebek do
  import Ecto.Query
  alias Jeopardy.GameState
  alias Jeopardy.Repo
  alias Jeopardy.Games.Game

  def handle(_, %{"value" => name}, %{game: game}) do
    assign_trebek(game, name)
  end

  def handle(_, name, %Game{} = game) do
    assign_trebek(game, name)
  end

  defp assign_trebek(game, name) do
    q =
      from g in Game,
        where: g.id == ^game.id and is_nil(g.trebek),
        select: g.id

    case q |> Repo.update_all_ts(set: [trebek: name]) do
      {0, _} ->
        {:failed, nil}

      {1, [_id]} ->
        GameState.update_round_status(game.code, "selecting_trebek", "introducing_roles")
    end
  end
end
