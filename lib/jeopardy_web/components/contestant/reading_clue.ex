defmodule JeopardyWeb.Components.Contestant.ReadingClue do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div class="w-screen h-[100dvh]">
      <.instructions><%= @game.trebek %> is reading the clue</.instructions>
    </div>
    """
  end
end
