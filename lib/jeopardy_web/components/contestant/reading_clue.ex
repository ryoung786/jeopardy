defmodule JeopardyWeb.Components.Contestant.ReadingClue do
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <p><%= @game.trebek %> is reading the clue</p>
    </div>
    """
  end
end
