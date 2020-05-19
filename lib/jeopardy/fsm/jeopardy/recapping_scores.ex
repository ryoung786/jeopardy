defmodule Jeopardy.FSM.Jeopardy.RecappingScores do
  alias Jeopardy.Games.Game
  alias Jeopardy.GameState

  def handle(_, _, %Game{} = g) do
    GameState.update_game_status(
      g.code, "jeopardy", "double_jeopardy", "revealing_board"
    )
  end
end
