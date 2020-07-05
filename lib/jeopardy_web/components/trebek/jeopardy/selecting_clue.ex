defmodule JeopardyWeb.Components.Trebek.Jeopardy.SelectingClue do
  use JeopardyWeb.Components.Base, :trebek

  @impl true
  def update(assigns, socket),
    do: {:ok, assign(socket, assigns) |> assign(selected_category: nil)}

  @impl true
  def handle_event("select_category", %{"category" => category_name}, socket),
    do: {:noreply, assign(socket, selected_category: category_name)}

  @impl true
  def handle_event("back", _params, socket),
    do: {:noreply, assign(socket, selected_category: nil)}

  @impl true
  def handle_event("select_clue", %{"clue_id" => clue_id}, socket) do
    Engine.event(:clue_selected, clue_id, socket.assigns.game.id)
    {:noreply, socket}
  end
end
