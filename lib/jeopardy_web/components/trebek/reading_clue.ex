defmodule JeopardyWeb.Components.Trebek.ReadingClue do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer

  def assign_init(socket, game) do
    assign(socket, category: game.clue.category, clue: game.clue.clue)
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3><%= @category %></h3>
      <h1><%= @clue %></h1>
      <button class="btn btn-primary" phx-click="continue">
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
