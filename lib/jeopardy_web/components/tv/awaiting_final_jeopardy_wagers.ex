defmodule JeopardyWeb.Components.Tv.AwaitingFinalJeopardyWagers do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    [category | _] = game.board.categories
    {:ok, assign(socket, category: category)}
  end

  def render(assigns) do
    ~H"""
    <h3><%= @category %></h3>
    """
  end
end
