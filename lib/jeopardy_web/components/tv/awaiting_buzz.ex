defmodule JeopardyWeb.Components.Tv.AwaitingBuzz do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.Timers

  def assign_init(socket, game) do
    assign(socket,
      category: game.clue.category,
      clue: game.clue.clue,
      time_remaining: Timers.time_remaining(game.fsm.data[:expires_at])
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3><%= @category %></h3>
      <h1><%= @clue %></h1>
      <.pie_timer timer={4_000} time_remaining={@time_remaining} />
    </div>
    """
  end
end
