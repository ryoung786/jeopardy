defmodule JeopardyWeb.Components.Game.PreJeopardy.SelectingTrebek do
  use JeopardyWeb.Components.Base, :game

  @impl true
  def handle_event("volunteer_to_host", _params, socket) do
    Engine.event(:select_trebek, socket.assigns.player.id, socket.assigns.game.id)
    {:noreply, socket}
  end
end
