defmodule JeopardyWeb.Components.Trebek.PreJeopardy.IntroducingRoles do
  use JeopardyWeb.Components.Base, :trebek

  @impl true
  def handle_event("advance_to_round", _params, socket) do
    Jeopardy.GameState.update_game_status(
      socket.assigns.game.code,
      "pre_jeopardy",
      "jeopardy",
      "revealing_board"
    )

    Jeopardy.Stats.create(socket.assigns.game)
    {:noreply, socket}
  end
end
