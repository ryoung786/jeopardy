defmodule JeopardyWeb.Components.Tv.ReadingClue do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    assign(socket, category: game.clue.category, clue: game.clue.clue)
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3><%= @category %></h3>
      <h1><%= @clue %></h1>
    </div>
    """
  end
end
