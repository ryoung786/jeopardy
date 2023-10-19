defmodule JeopardyWeb.Components.Tv.ReadingFinalJeopardyClue do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.FinalJeopardyAnswerSubmitted
  alias Jeopardy.FSM.Messages.TimerStarted
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
        <div
          class="w-8 h-8 opacity-50 absolute bottom-4"
          style="transform: translateX(calc(50vw - 50%))"
        >
          <.pie_timer :if={@time_remaining} timer={@timer} time_remaining={@time_remaining} />
        </div>
      </.tv>
    </div>
    """
  end

  def handle_game_server_msg(%TimerStarted{expires_at: expires_at}, socket) do
    {:ok, assign(socket, time_remaining: Timers.time_remaining(expires_at))}
  end

  def handle_game_server_msg(%FinalJeopardyAnswerSubmitted{}, socket) do
    {:ok, socket}
  end
end
