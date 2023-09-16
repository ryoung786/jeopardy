defmodule Jeopardy.FSM do
  defstruct [:state, data: nil]

  alias Jeopardy.Game

  def handle_action(action, game, data) do
    if action in game.fsm.state.valid_actions(),
      do: game.fsm.state.handle_action(action, game, data),
      else: {:error, :invalid_action}
  end

  @spec to_state(%Game{}, module()) :: %Game{}
  def to_state(%Game{} = game, module) do
    Map.put(game, :fsm, %__MODULE__{
      state: module,
      data: module.initial_data(game)
    })
  end

  def broadcast(%Jeopardy.Game{code: code}, message), do: broadcast(code, message)

  def broadcast(code, message) do
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, "games:#{code}", message)
  end
end
