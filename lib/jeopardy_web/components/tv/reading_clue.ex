defmodule JeopardyWeb.Components.Tv.ReadingClue do
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <h3><%= @game.clue.category %></h3>
      <h1><%= @game.clue.clue %></h1>
    </div>
    """
  end
end
