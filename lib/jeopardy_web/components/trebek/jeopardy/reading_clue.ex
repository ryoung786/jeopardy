defmodule JeopardyWeb.Components.Trebek.Jeopardy.ReadingClue do
  use JeopardyWeb.Components.Base, :trebek
  require Logger

  @impl true
  def handle_event("start_clue_timer", _params, socket) do
    Engine.event(:next, socket.assigns.game.id)
    {:noreply, socket}
  end
end
