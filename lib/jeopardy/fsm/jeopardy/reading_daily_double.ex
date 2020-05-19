defmodule Jeopardy.FSM.Jeopardy.ReadingDailyDouble do
  alias Jeopardy.Games.Game
  alias Jeopardy.GameState

  def handle(_, _, %Game{} = g) do
    GameState.update_round_status(g.code, "reading_daily_double", "answering_daily_double")
  end
end
