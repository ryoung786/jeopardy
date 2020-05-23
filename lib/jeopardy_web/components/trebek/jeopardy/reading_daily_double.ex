defmodule JeopardyWeb.Components.Trebek.Jeopardy.ReadingDailyDouble do
  use JeopardyWeb.Components.Base, :trebek

  @impl true
  def handle_event("start_daily_double_timer", _params, socket) do
    Jeopardy.GameState.update_round_status(
      socket.assigns.game.code,
      "reading_daily_double",
      "answering_clue"
    )

    {:noreply, socket}
  end
end
