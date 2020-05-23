defmodule JeopardyWeb.Components.Trebek.FinalJeopardy.ReadingClue do
  use JeopardyWeb.Components.Base, :trebek

  @impl true
  def handle_event("final_jeopardy_time_expired_click", _params, socket) do
    Jeopardy.GameState.update_round_status(
      socket.assigns.game.code,
      "reading_clue",
      "revealing_final_scores"
    )
  end
end
