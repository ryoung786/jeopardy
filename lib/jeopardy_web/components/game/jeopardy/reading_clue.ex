defmodule JeopardyWeb.Components.Game.Jeopardy.ReadingClue do
  use JeopardyWeb.Components.Base, :game

  @impl true
  def handle_event("early_buzz", _params, socket) do
    Engine.event(:early_buzz, socket.assigns.player.id, socket.assigns.game.id)
    {:noreply, socket}
  end
end
