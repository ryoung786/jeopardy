defmodule JeopardyWeb.Accounts.Drafts.GameLive.Index do
  use JeopardyWeb, :live_view
  alias Jeopardy.Drafts
  alias Jeopardy.Drafts.Game
  alias JeopardyWeb.Games.SearchComponent
  require Logger

  @impl true
  def mount(_params, %{"current_user_id" => current_user_id}, socket) do
    user = Jeopardy.Users.get_user!(current_user_id)

    {:ok,
     assign(socket,
       games: Drafts.list_games(user),
       current_user: user
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Game")
    |> assign(:game, Drafts.get_game!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Game")
    |> assign(:game, %Game{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Your Games")
    |> assign(:game, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    game = Drafts.get_game!(id)
    {:ok, _} = Drafts.delete_game(game)
    user = socket.assigns.user

    {:noreply, assign(socket, :games, Drafts.list_games(user))}
  end
end
