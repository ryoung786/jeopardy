defmodule Jeopardy.FSM.Jeopardy.AwaitingDailyDoubleWager do
  alias Jeopardy.Games.{Game, Clue}
  alias Jeopardy.GameState

  def handle(_, %{clue: clue,  wager: wager_amount}, %Game{} = g) do
    Clue.changeset(clue, %{wager: wager_amount}) |> Repo.update()
    GameState.update_round_status(g.code, "awaiting_daily_double_wager", "reading_daily_double")
  end
end
