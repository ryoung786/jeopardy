defmodule Jeopardy.FSM.FinalJeopardy.ReadingClue do
  alias Jeopardy.Games.{Game}
  alias Jeopardy.GameState

  def handle(_, _, %Game{} = game) do
    GameState.update_round_status(game.code, "reading_clue", "revealing_final_scores")
  end
end
