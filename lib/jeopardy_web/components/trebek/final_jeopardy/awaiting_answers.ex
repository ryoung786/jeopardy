defmodule JeopardyWeb.Components.Trebek.FinalJeopardy.AwaitingAnswers do
  use JeopardyWeb.Components.Base, :trebek

  @impl true
  def handle_event("start_timer_click", _params, socket) do
    Jeopardy.GameState.update_round_status(
      socket.assigns.game.code,
      "reading_clue",
      "awaiting_answers"
    )

    {:noreply, socket}
  end
end
