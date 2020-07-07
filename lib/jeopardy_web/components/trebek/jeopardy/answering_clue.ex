defmodule JeopardyWeb.Components.Trebek.Jeopardy.AnsweringClue do
  use JeopardyWeb.Components.Base, :trebek

  @impl true
  def handle_event("correct", _params, socket) do
    Engine.event(:correct, socket.assigns.game.id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("incorrect", _params, socket) do
    Engine.event(:incorrect, socket.assigns.game.id)
    {:noreply, socket}
  end
end
