defmodule Jeopardy.FSM.Jeopardy.RevealingBoard do
  alias Jeopardy.Games
  alias Jeopardy.Games.Game
  alias Jeopardy.GameState

  def handle(_, _, %Game{} = g) do
    Games.assign_board_control(g, :random)
    GameState.update_round_status(g.code, "revealing_board", "selecting_clue")
  end
end
