defmodule JeopardyWeb.Components.Tv.AwaitingBuzz do
  @moduledoc false
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
      <.tv contestants={@game.contestants}>
        <.clue category={@game.clue.category} clue={@game.clue.clue} />
        <:timer><.lights_timer timer_seconds={5} time_remaining={@time_remaining} /></:timer>
      </.tv>
    </div>
    """
  end
end
