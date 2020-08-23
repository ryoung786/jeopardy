defmodule JeopardyWeb.GamesLive do
  use JeopardyWeb, :live_view
  alias JeopardyWeb.Games.SearchComponent
  require Logger

  @impl true
  def mount(_params, %{"current_user_id" => user_id} = _session, socket) do
    user = Jeopardy.Users.get_user!(user_id)
    mount_with_current_user(user, socket)
  end

  @impl true
  def mount(_params, _session, socket), do: mount_with_current_user(nil, socket)

  defp mount_with_current_user(user, socket) do
    socket =
      socket
      |> assign(user: user)
      |> assign(confirm_selection: nil)
      |> assign(available_games_count: Jeopardy.Drafts.count_games())

    {:ok, socket}
  end

  @impl true
  def handle_params(_, _, socket),
    do: {:noreply, assign(socket, confirm_selection: nil)}

  @impl true
  def handle_info({:game_selected, id}, socket) do
    game = Jeopardy.Drafts.get_game!(id)
    {:noreply, assign(socket, confirm_selection: game)}
  end
end
