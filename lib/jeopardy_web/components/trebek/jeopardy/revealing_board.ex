defmodule JeopardyWeb.Components.Trebek.Jeopardy.RevealingBoard do
  use JeopardyWeb, :live_component
  require Logger

  @impl true
  def mount(socket) do
    {:ok, assign(socket, active_category_num: 0)}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(categories: get_zipped_categories(assigns))

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    JeopardyWeb.TrebekView.render(tpl_path(assigns), assigns)
  end

  @impl true
  def handle_event("next_category", _params, socket) do
    active_category_num = socket.assigns.active_category_num + 1
    {:noreply, assign(socket, active_category_num: active_category_num)}
  end

  @impl true
  def handle_event("finished_intro", _params, socket) do
    # Games.assign_board_control(g, :random)
    # GameState.update_round_status(g.code, "revealing_board", "selecting_clue")
    {:noreply, socket}
  end

  def get_zipped_categories(assigns) do
    categories =
      if assigns.game.status == "jeopardy" do
        assigns.game.jeopardy_round_categories
      else
        assigns.game.double_jeopardy_round_categories
      end

    Enum.zip(1..6, categories)
  end
end
