defmodule JeopardyWeb.Games.SearchComponent do
  use JeopardyWeb, :live_component
  alias Jeopardy.Drafts

  @impl true
  def mount(socket) do
    IO.inspect(socket.assigns, label: "[xxx] search component mount assigns")
    # defaults
    socket =
      socket
      |> assign(query: "")
      |> assign(user: nil)
      |> assign(filters: %{my_games: false})
      |> assign(hidden_filters: [])
      |> assign(games: [])

    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    IO.inspect(assigns, label: "[xxx] search component assigns")
    socket = assign(socket, assigns)

    {:ok, assign(socket, games: get_filtered_games(socket.assigns))}
  end

  @impl true
  def handle_event("search", %{"search" => %{"query" => q}}, socket) do
    {:noreply,
     assign(socket,
       query: q,
       games: get_filtered_games(%{socket.assigns | query: q})
     )}
  end

  @impl true
  def handle_event("select_game", %{"id" => game_id}, socket) do
    # send to parent
    draft_game = Drafts.get_game!(game_id)
    {:noreply, assign(socket, confirm_selection: draft_game)}
  end

  @impl true
  def handle_event("toggle_my_games", _, socket) do
    filters = Map.update!(socket.assigns.filters, :my_games, &(!&1))

    {:noreply,
     assign(socket,
       filters: filters,
       games: get_filtered_games(%{socket.assigns | filters: filters})
     )}
  end

  defp get_filtered_games(%{user: user, query: q, filters: filters}) do
    Jeopardy.Drafts.search_games(user, q, filters)
  end
end
