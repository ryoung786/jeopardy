defmodule Jeopardy.FSM do
  def handle_action(action, game, data) do
    if action in game.fsm_handler.valid_actions(),
      do: game.fsm_handler.handle_action(action, game, data),
      else: {:error, :invalid_action}
  end

  def broadcast(%Jeopardy.Game{code: code}, message), do: broadcast(code, message)

  def broadcast(code, message) do
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, "games:#{code}", message)
  end
end
