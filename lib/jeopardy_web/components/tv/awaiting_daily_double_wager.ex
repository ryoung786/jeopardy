defmodule JeopardyWeb.Components.Tv.AwaitingDailyDoubleWager do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants} buzzer={@game.board_control}>
        <.clue category={@game.clue.category} daily_double_background?={@game.clue.daily_double?}>
          DAILY DOUBLE
        </.clue>
        />
      </.tv>
    </div>
    """
  end
end
