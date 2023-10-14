defmodule JeopardyWeb.Components.Tv.AwaitingDailyDoubleWager do
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants} buzzer={@game.buzzer}>
        <.clue category={@game.clue.category} clue="Daily Double" />
      </.tv>
    </div>
    """
  end
end
