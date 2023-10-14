defmodule JeopardyWeb.Components.Tv.SelectingClue do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    assign(socket,
      categories: game.board.categories,
      clues:
        Map.new(game.board.clues, fn {category, clues} ->
          {category, Map.keys(clues)}
        end)
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.board categories={@game.categories} clues={@game.board} />
      </.tv>
    </div>
    """
  end
end
