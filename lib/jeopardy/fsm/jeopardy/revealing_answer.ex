defmodule Jeopardy.FSM.Jeopardy.RevealingAnswer do
  use Jeopardy.FSM

  @impl true
  def handle(:next, _, %State{} = state) do
    Jeopardy.Stats.update(state.game)
    {:ok, State.update_round(state, "selecting_clue")}
  end
end
