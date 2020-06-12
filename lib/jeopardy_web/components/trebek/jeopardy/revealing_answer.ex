defmodule JeopardyWeb.Components.Trebek.Jeopardy.RevealingAnswer do
  use JeopardyWeb.Components.Base, :trebek
  require Logger

  @impl true
  def handle_event("revealed_answer", _params, socket) do
    Jeopardy.Stats.update(socket.assigns.game)
    Jeopardy.GameState.to_selecting_clue(socket.assigns.game)
    {:noreply, socket}
  end
end
