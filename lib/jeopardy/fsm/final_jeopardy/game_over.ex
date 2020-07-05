defmodule Jeopardy.FSM.FinalJeopardy.GameOver do
  use Jeopardy.FSM

  def handle(_, _, state), do: state
end
