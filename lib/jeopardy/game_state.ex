defmodule Jeopardy.GameState do
  import Ecto.Query, warn: false
  alias Jeopardy.Games, as: G
  alias Jeopardy.Games.{Game}
  alias Jeopardy.Repo

  def update_round_status(code, from, to) do
    case (from g in Game, where: g.code == ^code and g.round_status == ^from, select: g.id)
    |> Repo.update_all_ts(set: [round_status: to]) do
      {0, _} -> {:failed, nil}
      {1, [id]} ->
        Phoenix.PubSub.broadcast(Jeopardy.PubSub, code, {:round_status_change, to})
        {:ok, G.get_game!(id)}
    end
  end

  def update_game_status(code, from, to, round) do
    case (from g in Game, where: g.code == ^code and g.status == ^from, select: g.id)
    |> Repo.update_all_ts(set: [status: to, round_status: round]) do
      {0, _} -> {:failed, nil}
      {1, [id]} ->
        Phoenix.PubSub.broadcast(Jeopardy.PubSub, code, {:game_status_change, to})
        {:ok, G.get_game!(id)}
    end
  end
end
