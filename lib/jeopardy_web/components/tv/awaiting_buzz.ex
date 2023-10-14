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
      <.tv contestants={@game.contestants}>
        <.clue category={@game.clue.category} clue={@game.clue.clue} />
        <.lights_timer timer_seconds={5} time_remaining={@time_remaining} />
      </.tv>
    </div>
    """
  end
end
