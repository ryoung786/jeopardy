defmodule JeopardyWeb.Components.Trebek.SelectingClue do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer

  def assign_init(socket, _game) do
    assign(socket, category: nil)
  end

  def handle_event("back", _params, socket) do
    {:noreply, assign(socket, category: nil)}
  end

  def handle_event("category-selected", %{"category" => category}, socket) do
    {:noreply, assign(socket, category: category)}
  end

  def handle_event("clue-selected", %{"clue" => clue}, socket) do
    clue = String.to_integer(clue)
    code = socket.assigns.code
    category = socket.assigns.category

    with {:ok, _game} <- GameServer.action(code, :clue_selected, {category, clue}) do
      {:noreply, socket}
    else
      {:error, :clue_already_asked} -> {:noreply, socket}
      _ -> {:noreply, socket}
    end
  end
end
