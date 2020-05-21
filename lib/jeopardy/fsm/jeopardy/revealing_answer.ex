defmodule Jeopardy.FSM.Jeopardy.RevealingAnswer do
  alias Jeopardy.Games.Game
  alias Jeopardy.GameState
  require Logger

  def handle("revealed_answer", _, %Game{} = g) do
    GameState.to_selecting_clue(g)
  end

  def handle(event, _, %Game{} = _g) do
    Logger.info("Unsanctioned event in Jeopardy RevealingAnswer: #{inspect(event)}")
  end
end
