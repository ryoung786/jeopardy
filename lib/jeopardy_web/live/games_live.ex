defmodule JeopardyWeb.GamesLive do
  @moduledoc false
  use JeopardyWeb, :live_view

  def render(assigns) do
    ~H"""
    <div>
      <h2>Play a random game from the Jeopardy Archives</h2>
      <.link class="btn btn-primary" phx-click="random_game">Quick Start</.link>
    </div>
    """
  end

  def handle_event("random_game", _data, socket) do
    code = Jeopardy.GameServer.new_game_server()
    {:noreply, push_navigate(socket, to: ~p"/games/#{code}")}
  end
end
