defmodule JeopardyWeb.GamesLive do
  use JeopardyWeb, :live_view
  alias Jeopardy.Drafts
  require Logger

  @impl true
  def mount(_params, %{"current_user_id" => user_id} = _session, socket) do
    user = Jeopardy.Users.get_user!(user_id)
    mount_with_current_user(user, socket)
  end

  @impl true
  def mount(_params, _session, socket), do: mount_with_current_user(nil, socket)

  defp mount_with_current_user(user, socket) do
    games = Jeopardy.Drafts.list_games()

    socket =
      socket
      |> assign(user: user)
      |> assign(games: games)
      |> assign(query: "")
      |> assign(filters: %{my_games: false})
      |> assign(confirm_selection: nil)
      |> assign(available_games_count: Enum.count(games))

    {:ok, socket}
  end

  @impl true
  def handle_params(_, _, socket),
    do: {:noreply, assign(socket, confirm_selection: nil)}

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
    draft_game = Drafts.get_game!(game_id)
    # Jeopardy.Games.create_from_draft_game(draft_game)
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
