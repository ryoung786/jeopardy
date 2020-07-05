defmodule JeopardyWeb.Components.Trebek.Jeopardy.ReadingDailyDouble do
  use JeopardyWeb.Components.Base, :trebek

  @impl true
  def handle_event("start_daily_double_timer", _params, socket) do
    Engine.event(:next, socket.assigns.game.id)
    {:noreply, socket}
  end
end
