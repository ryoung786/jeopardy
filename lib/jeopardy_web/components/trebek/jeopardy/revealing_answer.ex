defmodule JeopardyWeb.Components.Trebek.Jeopardy.RevealingAnswer do
  use JeopardyWeb.Components.Base, :trebek
  require Logger

  @impl true
  def handle_event("revealed_answer", _params, socket) do
    Engine.event(:next, socket.assigns.game.id)
    {:noreply, socket}
  end
end
