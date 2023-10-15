defmodule JeopardyWeb.Components.Contestant.ReadingClue do
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <.instructions><%= @game.trebek %> is reading the clue</.instructions>
    </div>
    """
  end
end
