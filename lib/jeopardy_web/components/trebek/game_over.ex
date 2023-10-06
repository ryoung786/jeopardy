defmodule JeopardyWeb.Components.Trebek.GameOver do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer

  def render(assigns) do
    ~H"""
    <div>
      <.button class="btn btn-primary" phx-target={@myself} phx-click="play-again">
        Play Again
      </.button>
    </div>
    """
  end

  def handle_event("play-again", _params, socket) do
    GameServer.action(socket.assigns.code, {:play_again})
    {:noreply, socket}
  end
end
