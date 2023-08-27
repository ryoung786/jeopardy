defmodule Jeopardy.FSM do
  alias Jeopardy.FSM

  def handle_action(action, game, data) do
    handler = get_handler(game.status)

    if action in handler.valid_actions(),
      do: handler.handle_action(action, game, data),
      else: {:error, :invalid_action}
  end

  def get_handler(:awaiting_players), do: FSM.AwaitingPlayers
end
