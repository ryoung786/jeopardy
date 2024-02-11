defmodule JeopardyWeb.Components.Trebek.GameOver do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.GameServer

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[1fr_auto] min-h-[100dvh]">
      <.trebek_clue><span>Game Over</span></.trebek_clue>
      <div class="p-4 grid">
        <.button class="btn btn-primary" phx-target={@myself} phx-click="play-again">
          Play Again
        </.button>
      </div>
    </div>
    """
  end

  def handle_event("play-again", _params, socket) do
    GameServer.action(socket.assigns.code, :play_again)
    {:noreply, socket}
  end
end
