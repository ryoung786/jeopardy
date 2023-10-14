defmodule JeopardyWeb.Components.Trebek.ReadingClue do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer

  def render(assigns) do
    ~H"""
    <div>
      <h3><%= @game.clue.category %></h3>
      <h1><%= @game.clue.clue %></h1>
      <button class="btn btn-primary" phx-click="continue" phx-target={@myself}>
        Finished Reading
      </button>
    </div>
    """
  end

  def handle_event("continue", _params, socket) do
    GameServer.action(socket.assigns.code, :finished_reading)
    {:noreply, socket}
  end
end
