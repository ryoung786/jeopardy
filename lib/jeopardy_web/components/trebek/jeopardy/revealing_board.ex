defmodule JeopardyWeb.Components.Trebek.Jeopardy.RevealingBoard do
  use JeopardyWeb.Components.Base, :trebek
  require Logger
  alias Jeopardy.Games
  alias Jeopardy.GameState

  @impl true
  def mount(socket), do: {:ok, assign(socket, active_category_num: 0)}

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(categories: get_zipped_categories(assigns))

    {:ok, socket}
  end

  @impl true
  def handle_event("next_category", _params, socket) do
    active_category_num = socket.assigns.active_category_num + 1
    broadcast(active_category_num, socket)
    {:noreply, assign(socket, active_category_num: active_category_num)}
  end

  @impl true
  def handle_event("finished_intro", _params, socket) do
    Games.assign_board_control(socket.assigns.game, :random)
    GameState.update_round_status(socket.assigns.game.code, "revealing_board", "selecting_clue")
    {:noreply, socket}
  end

  defp get_zipped_categories(assigns) do
    categories =
      case assigns.game.status do
        "jeopardy" -> assigns.game.jeopardy_round_categories
        _ -> assigns.game.double_jeopardy_round_categories
      end

    Enum.zip(1..6, categories)
  end

  defp broadcast(active_category_num, socket) do
    Phoenix.PubSub.broadcast(
      Jeopardy.PubSub,
      socket.assigns.game.code,
      {:next_category,
       %{
         active_category_num: active_category_num,
         status: socket.assigns.game.status,
         round_status: socket.assigns.game.round_status
       }}
    )
  end
end