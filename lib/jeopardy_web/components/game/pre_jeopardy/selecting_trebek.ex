defmodule JeopardyWeb.Components.Game.PreJeopardy.SelectingTrebek do
  use JeopardyWeb.Components.Base, :game

  @impl true
  def handle_event("volunteer_to_host", _params, socket) do
    name = socket.assigns.name
    Jeopardy.Games.assign_trebek(socket.assigns.game, name)
    {:noreply, socket}
  end
end
