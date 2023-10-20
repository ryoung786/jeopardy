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
        <.clue><%= @game.clue.category %></.clue>
        <div
          class="w-8 h-8 opacity-50 absolute bottom-4"
          style="transform: translateX(calc(50vw - 50%))"
        >
          <.pie_timer time_remaining={@time_remaining} />
        </div>
      </.tv>
    </div>
    """
  end
end
