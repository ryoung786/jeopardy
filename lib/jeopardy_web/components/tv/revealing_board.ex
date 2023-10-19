defmodule JeopardyWeb.Components.Tv.RevealingBoard do
  @moduledoc false
  use JeopardyWeb.FSMComponent

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
      <.tv contestants={@contestants}>
        <.board categories={@game.categories} clues={@game.board} category_reveal_index={@index} />
      </.tv>
    </div>
    """
  end

  def handle_game_server_msg(%RevealedCategory{index: index}, socket) do
    {:ok, assign(socket, index: index)}
  end
end
