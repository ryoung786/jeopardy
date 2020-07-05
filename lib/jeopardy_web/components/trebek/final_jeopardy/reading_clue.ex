defmodule JeopardyWeb.Components.Trebek.FinalJeopardy.ReadingClue do
  use JeopardyWeb.Components.Base, :trebek

  @impl true
  def handle_event("start_timer_click", _params, socket) do
    Engine.event(:trebek_advance, socket.assigns.game.id)
    {:noreply, socket}
  end
end
