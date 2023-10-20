defmodule JeopardyWeb.Components.Tv.ReadingClue do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.clue category={@game.clue.category}><%= @game.clue.clue %></.clue>
      </.tv>
    </div>
    """
  end
end
