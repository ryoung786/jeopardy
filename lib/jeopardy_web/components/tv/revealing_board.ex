defmodule JeopardyWeb.Components.Tv.RevealingBoard do
  use JeopardyWeb.FSMComponent

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

  def handle_game_server_msg({:revealed_category, index}, socket) do
    {:ok, assign(socket, index: index)}
  end
end
