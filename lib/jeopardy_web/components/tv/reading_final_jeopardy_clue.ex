defmodule JeopardyWeb.Components.Tv.ReadingFinalJeopardyClue do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.Timers

  @timer 60_000

  def assign_init(socket, game) do
    assign(socket,
      timer: @timer,
      time_remaining: Timers.time_remaining(game.fsm.data[:expires_at])
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.clue category={@game.clue.category} clue={@game.clue.clue} />
        <.pie_timer :if={@time_remaining} timer={@timer} time_remaining={@time_remaining} />
      </.tv>
    </div>
    """
  end

  def handle_game_server_msg({:timer_started, expires_at}, socket) do
    {:ok, assign(socket, time_remaining: Timers.time_remaining(expires_at))}
  end
end
