defmodule Jeopardy.FSM.FinalJeopardy.ReadingClue do
  use Jeopardy.FSM

  @impl true
  def handle(:trebek_advance, _, %State{} = state) do
    {:ok, State.update_round(state, "awaiting_answers")}
  end
end
