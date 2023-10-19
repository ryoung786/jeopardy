defmodule JeopardyWeb.Components.Tv.AwaitingDailyDoubleWager do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants} buzzer={@game.board_control}>
        <.clue
          category={@game.clue.category}
          clue="DAILY DOUBLE"
          daily_double_background?={@game.clue.daily_double?}
        />
      </.tv>
    </div>
    """
  end
end
