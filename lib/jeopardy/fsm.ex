defmodule Jeopardy.FSM do
  defstruct [:state, data: nil]

  def handle_action(action, game, data) do
    if action in game.fsm.state.valid_actions(),
      do: game.fsm.state.handle_action(action, game, data),
      else: {:error, :invalid_action}
  end

  def to_state(module, %Jeopardy.Game{} = game \\ %Jeopardy.Game{}) do
    %__MODULE__{
      state: module,
      data: module.initial_data(game)
    }
  end

  def broadcast(%Jeopardy.Game{code: code}, message), do: broadcast(code, message)

  def broadcast(code, message) do
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, "games:#{code}", message)
  end
end
