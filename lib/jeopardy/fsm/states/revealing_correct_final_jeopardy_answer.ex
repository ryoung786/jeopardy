defmodule Jeopardy.FSM.RevealingCorrectFinalJeopardyAnswer do
  @moduledoc false
  use Jeopardy.FSM.State

  alias Jeopardy.FSM

  @impl true
  def valid_actions, do: ~w/continue/a

  @impl true
  def handle_action(:continue, game, _data), do: {:ok, FSM.to_state(game, FSM.GameOver)}
end
