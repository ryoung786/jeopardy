defmodule JeopardyWeb.Components.TV.PreJeopardy.SelectingTrebek do
  use JeopardyWeb.Components.Base, :tv

  @impl true
  def handle_event("trebek_selection", %{"value" => name}, socket) do
    Jeopardy.Games.assign_trebek(socket.assigns.game, name)
    {:noreply, socket}
  end
end
