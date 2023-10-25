defmodule JeopardyWeb.GamesLive do
  @moduledoc false
  use JeopardyWeb, :live_view

  on_mount {JeopardyWeb.UserAuth, :mount_current_user}

  def render(assigns) do
    ~H"""
    <.main flash={@flash}>
      <div class="flex flex-col gap-8 place-items-center">
        <h2 class="text-4xl text-center max-w-md">Play a random game from the Jeopardy Archives</h2>
        <.link class="btn btn-primary" phx-click="random_game">Quick Start</.link>
      </div>
    </.main>
    """
  end

  def handle_event("random_game", _data, socket) do
    code = Jeopardy.GameServer.new_game_server()
    {:noreply, redirect(socket, to: ~p"/games/#{code}")}
  end
end
