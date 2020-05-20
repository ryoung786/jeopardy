defmodule Jeopardy.FSM.PreJeopardy.IntroducingRoles do
  alias Jeopardy.GameState
  alias Jeopardy.Games.Game

  def handle(_, _, %Game{} = game) do
    GameState.update_game_status(
      game.code, "pre_jeopardy", "jeopardy", "revealing_board"
    )
  end
end
