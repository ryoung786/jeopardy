defmodule JeopardyWeb.Games.SearchComponent do
  use JeopardyWeb, :live_component
  alias Jeopardy.Drafts

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(user: nil)
      |> assign(filters: [])
      |> assign(hidden_filters: [])
      |> assign(edit_delete_col: false)
      |> assign(page: 1)

    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns) |> assign(query: "")

    {:ok, assign(socket, games: get_filtered_games(socket.assigns))}
  end

  @impl true
  def handle_event("search", %{"search" => %{"query" => q}}, socket) do
    socket = assign(socket, query: q, page: 1)
    {:noreply, assign(socket, games: get_filtered_games(socket.assigns))}
  end

  @impl true
  def handle_event("prev_page", _params, socket) do
    socket = assign(socket, page: socket.assigns.page - 1)
    {:noreply, assign(socket, games: get_filtered_games(socket.assigns))}
  end

  @impl true
  def handle_event("next_page", _params, socket) do
    socket = assign(socket, page: socket.assigns.page + 1)
    {:noreply, assign(socket, games: get_filtered_games(socket.assigns))}
  end

  @impl true
  def handle_event("select_game", %{"id" => game_id}, socket) do
    send(self(), {:game_selected, game_id})
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_my_games", _, socket) do
    filters = toggle(socket.assigns.filters, :my_games)
    socket = assign(socket, filters: filters, page: 1)

    {:noreply, assign(socket, games: get_filtered_games(socket.assigns))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    id = String.to_integer(id)
    {:ok, _} = Drafts.delete_game(%Drafts.Game{id: id})
    send(self(), {:game_deleted, id})

    {:noreply, assign(socket, games: get_filtered_games(socket.assigns))}
  end

  defp get_filtered_games(%{user: user, query: q, filters: filters, page: page}),
    do: Drafts.search_games(user, q, filters, page: page)

  defp toggle(arr, x) do
    if x in arr, do: List.delete(arr, x), else: [x | arr]
  end
end
