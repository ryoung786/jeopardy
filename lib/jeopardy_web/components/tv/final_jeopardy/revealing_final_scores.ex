defmodule JeopardyWeb.Components.TV.FinalJeopardy.RevealingFinalScores do
  use JeopardyWeb.Components.Base, :tv

  @impl true
  def handle_event("game_over", _params, socket) do
    Jeopardy.GameState.update_round_status(
      socket.assigns.game.code,
      "revealing_final_scores",
      "game_over"
    )

    Jeopardy.Stats.update(socket.assigns.game)

    {:noreply, socket}
  end
end
