defmodule JeopardyWeb.Components.Trebek.RevealingCorrectFinalJeopardyAnswer do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.GameServer

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[1fr_auto] min-h-[100dvh]">
      <.trebek_clue><span>Game Over</span></.trebek_clue>
      <div class="p-4 grid">
        <.button class="btn btn-primary" phx-target={@myself} phx-click="game-over">
          Continue
        </.button>
      </div>
    </div>
    """
  end

  def handle_event("game-over", _params, socket) do
    GameServer.action(socket.assigns.code, :continue)
    {:noreply, socket}
  end
end
