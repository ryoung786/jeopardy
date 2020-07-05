defmodule Jeopardy.FSM.Jeopardy.ReadingDailyDouble do
  use Jeopardy.FSM

  @impl true
  def handle(:next, _, %State{} = state) do
    {:ok, State.update_round(state, "answering_clue")}
  end
end
