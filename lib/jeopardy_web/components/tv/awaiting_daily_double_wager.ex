defmodule JeopardyWeb.Components.Tv.AwaitingDailyDoubleWager do
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <h3><%= @game.clue.category %></h3>
      <h3>Daily Double</h3>
    </div>
    """
  end
end
