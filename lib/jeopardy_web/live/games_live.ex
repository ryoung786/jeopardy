defmodule JeopardyWeb.GamesLive do
  use JeopardyWeb, :live_view
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
      |> assign(available_games_count: Enum.count(games))

    {:ok, socket}
  end

  @impl true
  def handle_event("search", %{"search" => %{"query" => q}}, socket) do
    filtered_games = Jeopardy.Drafts.search_games(socket.assigns.user, q)
    {:noreply, assign(socket, games: filtered_games)}
  end

  @impl true
  def handle_event("select_game", %{"id" => game_id}, socket) do
    IO.inspect(game_id, label: "[xxx] clicked")

    draft_game = Drafts.get_game!(game_id)
    Jeopardy.Games.create_from_draft_game(draft_game)
    {:noreply, socket}
  end
end
