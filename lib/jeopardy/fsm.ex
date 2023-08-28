defmodule Jeopardy.FSM do
  alias Jeopardy.FSM

  def handle_action(action, game, data) do
    handler = get_handler(game.status)

    if action in handler.valid_actions(),
      do: handler.handle_action(action, game, data),
      else: {:error, :invalid_action}
  end

  def get_handler(:awaiting_players), do: FSM.AwaitingPlayers
  def get_handler(:selecting_trebek), do: FSM.SelectingTrebek
  def get_handler(:game_over), do: FSM.GameOver

  def broadcast(%Jeopardy.Game{code: code}, message), do: broadcast(code, message)

  def broadcast(code, message) do
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, "games:#{code}", message)
  end
end
