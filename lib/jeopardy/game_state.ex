defmodule Jeopardy.GameState do
  import Ecto.Query, warn: false
  alias Jeopardy.Games, as: G
  alias Jeopardy.Games.{Game}
  alias Jeopardy.Repo

  def update_round_status(code, from, to) do
    case from(g in Game, where: g.code == ^code and g.round_status == ^from, select: g.id)
         |> Repo.update_all_ts(set: [round_status: to]) do
      {0, _} ->
        {:failed, nil}

      {1, [id]} ->
        Phoenix.PubSub.broadcast(Jeopardy.PubSub, code, {:round_status_change, to})
        {:ok, G.get_game!(id)}
    end
  end

  def update_game_status(code, from, to, new_round) do
    case from(g in Game, where: g.code == ^code and g.status == ^from, select: g.id)
         |> Repo.update_all_ts(set: [status: to, round_status: new_round]) do
      {0, _} ->
        {:failed, nil}

      {1, [id]} ->
        Phoenix.PubSub.broadcast(Jeopardy.PubSub, code, {:game_status_change, to})
        {:ok, G.get_game!(id)}
    end
  end

  def to_selecting_clue(%Game{} = g) do
    case Game.round_over?(g) do
      true -> update_round_status(g.code, g.round_status, "recapping_scores")
      _ -> update_round_status(g.code, g.round_status, "selecting_clue")
    end

    g
  end
end
