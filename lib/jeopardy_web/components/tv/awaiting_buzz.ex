defmodule JeopardyWeb.Components.Tv.AwaitingBuzz do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.Timers

  def assign_init(socket, game) do
    assign(socket,
      time_remaining: Timers.time_remaining(game.fsm.data[:expires_at])
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3><%= @game.clue.category %></h3>
      <h1><%= @game.clue.clue %></h1>
      <.lights_timer timer_seconds={5} time_remaining={@time_remaining} />
    </div>
    """
  end
end
