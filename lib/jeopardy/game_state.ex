defmodule Jeopardy.GameState do
  import Ecto.Query, warn: false
  alias Jeopardy.Games, as: G
  alias Jeopardy.Games.{Game}
  alias Jeopardy.Repo

  @states %{
    pre_jeopardy: ~w(awaiting_start selecting_trebek introducing_roles),
    jeopardy: ~w(revealing_board selecting_clue reading_clue awaiting_buzzer
      answering_clue awaiting_daily_double_wager reading_daily_double answering_daily_double
      revealing_answer recapping_scores),
    double_jeopardy: ~w(revealing_board selecting_clue reading_clue awaiting_buzzer
      answering_clue awaiting_daily_double_wager reading_daily_double answering_daily_double
      revealing_answer recapping_scores),
    final_jeopardy: ~w(revealing_category reading_clue revealing_final_scores)
  }

  def update_round_status(code, from, to) do
    case (from g in Game, where: g.code == ^code and g.round_status == ^from, select: g.id)
    |> Repo.update_all_ts(set: [round_status: to]) do
      {0, _} -> {:failed, nil}
      {1, [id]} ->
        Phoenix.PubSub.broadcast(Jeopardy.PubSub, code, {:round_status_change, to})
        {:ok, G.get_game!(id)}
    end
  end

  def update_game_status(code, from, to, new_round) do
    case (from g in Game, where: g.code == ^code and g.status == ^from, select: g.id)
    |> Repo.update_all_ts(set: [status: to, round_status: new_round]) do
      {0, _} -> {:failed, nil}
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
