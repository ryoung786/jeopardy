defmodule Jeopardy.FSM.Jeopardy.RecappingScores do
  alias Jeopardy.Games.Game
  alias Jeopardy.GameState

  def handle(_, _, %Game{} = g) do
    case g.status do
      "jeopardy" -> GameState.update_game_status(g.code, "jeopardy", "double_jeopardy", "revealing_board")
      "double_jeopardy" -> GameState.update_game_status(g.code, "double_jeopardy", "final_jeopardy", "revealing_category")
    end
  end
end
