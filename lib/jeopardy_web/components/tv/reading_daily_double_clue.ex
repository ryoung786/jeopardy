defmodule JeopardyWeb.Components.Tv.ReadingDailyDoubleClue do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants} buzzer={@game.board_control}>
        <.clue category={@game.clue.category}><%= @game.clue.clue %></.clue>
      </.tv>
    </div>
    """
  end
end
