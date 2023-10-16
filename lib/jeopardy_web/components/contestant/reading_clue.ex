defmodule JeopardyWeb.Components.Contestant.ReadingClue do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div class="w-screen h-screen">
      <.instructions><%= @game.trebek %> is reading the clue</.instructions>
    </div>
    """
  end
end
