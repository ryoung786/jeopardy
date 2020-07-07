defmodule JeopardyWeb.Components.TV.PreJeopardy.SelectingTrebek do
  use JeopardyWeb.Components.Base, :tv

  @impl true
  def handle_event("trebek_selection", %{"value" => player_id}, socket) do
    Engine.event(
      :select_trebek,
      String.to_integer(player_id),
      socket.assigns.game.id
    )

    {:noreply, socket}
  end
end
