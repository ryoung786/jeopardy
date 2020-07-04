defmodule JeopardyWeb.Components.Trebek.PreJeopardy.IntroducingRoles do
  use JeopardyWeb.Components.Base, :trebek

  @impl true
  def handle_event("advance_to_round", _params, socket) do
    Engine.event(:next, socket.assigns.game.id)
    {:noreply, socket}
  end
end
