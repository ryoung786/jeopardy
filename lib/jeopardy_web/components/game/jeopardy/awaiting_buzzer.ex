defmodule JeopardyWeb.Components.Game.Jeopardy.AwaitingBuzzer do
  use JeopardyWeb.Components.Base, :game
  require Logger

  @impl true
  def handle_event("buzz", _params, socket) do
    Engine.event(:buzz, socket.assigns.player.id, socket.assigns.game.id)
    {:noreply, socket}
  end
end
