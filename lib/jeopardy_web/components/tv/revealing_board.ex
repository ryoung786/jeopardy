defmodule JeopardyWeb.Components.Tv.RevealingBoard do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.PlayerRemoved
  alias Jeopardy.FSM.Messages.RevealedCategory

  def assign_init(socket, game) do
    assign(socket,
      categories: game.board.categories,
      index: game.fsm.data.revealed_category_count - 1
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.board categories={@game.categories} clues={@game.board} category_reveal_index={@index} />
      </.tv>
    </div>
    """
  end

  def handle_game_server_msg(%RevealedCategory{index: index}, socket) do
    {:ok, assign(socket, index: index)}
  end

  def handle_game_server_msg(%PlayerRemoved{name: name}, socket), do: handle_tv_player_removed(name, socket)
  def handle_game_server_msg(_, socket), do: {:ok, socket}
end
