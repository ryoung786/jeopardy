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
  def handle_info({:game_selected, id}, socket) do
    game = Jeopardy.Drafts.get_game!(id)
    {:noreply, push_redirect(socket, to: Routes.game_show_path(socket, :show, game))}
  end

  @impl true
  def handle_info({:game_deleted, _id}, socket) do
    {:noreply, put_flash(socket, :info, "Successfully deleted game")}
  end

  def mygames_component(socket, assigns) do
    live_component(socket, SearchComponent,
      id: :search_component,
      user: assigns.current_user,
      hidden_filters: [:my_games],
      filters: [:my_games],
      edit_delete_col: true
    )
  end
end
