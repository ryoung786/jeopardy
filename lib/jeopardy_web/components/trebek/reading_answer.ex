defmodule JeopardyWeb.Components.Trebek.ReadingAnswer do
  use JeopardyWeb.FSMComponent

  alias Jeopardy.GameServer

  def assign_init(socket, game) do
    assign(socket, answer: game.clue.answer)
  end

  def render(assigns) do
    ~H"""
    <div>
      <p><%= @answer %></p>
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
