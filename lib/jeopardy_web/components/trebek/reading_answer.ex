defmodule JeopardyWeb.Components.Trebek.ReadingAnswer do
  use JeopardyWeb.FSMComponent

  alias Jeopardy.GameServer

  def render(assigns) do
    ~H"""
    <div>
      <p><%= @game.clue.answer %></p>
      <.button class="btn-primary" phx-click="finished-reading" phx-target={@myself}>
        Continue
      </.button>
    </div>
    """
  end

  def handle_event("finished-reading", _params, socket) do
    GameServer.action(socket.assigns.code, :finished_reading)
    {:noreply, socket}
  end
end
