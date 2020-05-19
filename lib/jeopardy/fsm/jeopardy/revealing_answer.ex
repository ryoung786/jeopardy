defmodule Jeopardy.FSM.Jeopardy.RevealingAnswer do
  alias Jeopardy.Games.Game
  alias Jeopardy.GameState

  def handle(_, _, %Game{} = g) do
    GameState.to_selecting_clue(g)
  end
end
