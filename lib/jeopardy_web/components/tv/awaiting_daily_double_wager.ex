defmodule JeopardyWeb.Components.Tv.AwaitingDailyDoubleWager do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    {:ok, assign(socket, game.clue.category)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3><%= @category %></h3>
      <h3>Daily Double</h3>
    </div>
    """
  end
end
