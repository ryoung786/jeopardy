defmodule JeopardyWeb.Components.Trebek.Jeopardy.RevealingAnswer do
  use JeopardyWeb.Components.Base, :trebek
  require Logger

  @impl true
  def handle_event("revealed_answer", _params, socket) do
    Jeopardy.GameState.update_round_status(
      socket.assigns.game.code,
      "revealing_answer",
      "selecting_clue"
    )

    {:noreply, socket}
  end
end
