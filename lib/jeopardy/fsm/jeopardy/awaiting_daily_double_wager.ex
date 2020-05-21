defmodule Jeopardy.FSM.Jeopardy.AwaitingDailyDoubleWager do
  alias Jeopardy.Games.{Clue}
  alias Jeopardy.GameState

  def handle(_, %{clue: clue, wager: wager_amount}, game) do
    Clue.changeset(clue, %{wager: wager_amount}) |> Jeopardy.Repo.update()

    GameState.update_round_status(
      game.code,
      "awaiting_daily_double_wager",
      "reading_daily_double"
    )
  end
end
