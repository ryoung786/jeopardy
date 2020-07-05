defmodule JeopardyWeb.Components.Trebek.Jeopardy.RecappingScores do
  use JeopardyWeb.Components.Base, :trebek

  @impl true
  def handle_event("advance_to_double_jeopardy", _params, socket) do
    Engine.event(:to_double_jeopardy, socket.assigns.game_id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("advance_to_final_jeopardy", _params, socket) do
    Engine.event(:to_final_jeopardy, socket.assigns.game_id)
    {:noreply, socket}
  end
end
