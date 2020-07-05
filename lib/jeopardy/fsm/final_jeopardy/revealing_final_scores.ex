defmodule Jeopardy.FSM.FinalJeopardy.RevealingFinalScores do
  use Jeopardy.FSM

  @impl true
  def handle(:reveal_complete, _, %State{} = state) do
    Jeopardy.Stats.update(state.game)
    {:ok, State.update_round(state, "game_over")}
  end
end
