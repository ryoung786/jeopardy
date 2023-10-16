defmodule JeopardyWeb.Components.Tv.AwaitingFinalJeopardyWagers do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.Timers

  def assign_init(socket, game) do
    assign(socket, time_remaining: Timers.time_remaining(game.fsm.data[:expires_at]))
  end

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.clue clue={@game.clue.category} />
        <.pie_timer time_remaining={@time_remaining} />
      </.tv>
    </div>
    """
  end
end
