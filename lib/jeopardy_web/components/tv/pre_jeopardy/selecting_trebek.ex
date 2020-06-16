defmodule JeopardyWeb.Components.TV.PreJeopardy.SelectingTrebek do
  use JeopardyWeb.Components.Base, :tv
  alias Jeopardy.Games

  @impl true
  def handle_event("trebek_selection", %{"value" => name}, socket) do
    Jeopardy.Games.assign_trebek(socket.assigns.game, name)
    {:noreply, socket}
  end

  @impl true
  def update(assigns, socket) do
    audience =
      socket.assigns[:audience] || Games.get_all_players(assigns.game) |> Enum.map(& &1.name)

    {:ok,
     assign(socket, assigns)
     |> assign(audience: audience)}
  end
end
