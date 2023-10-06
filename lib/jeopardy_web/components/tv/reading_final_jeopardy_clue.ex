defmodule JeopardyWeb.Components.Tv.ReadingFinalJeopardyClue do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.Timers

  def assign_init(socket, game) do
    {:ok,
     assign(socket,
       category: game.clue.category,
       clue: game.clue.clue,
       time_remaining: Timers.time_remaining(game.fsm.data[:expires_at])
     )}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3><%= @category %></h3>
      <h3><%= @clue %></h3>
      <.pie_timer :if={@time_remaining} timer={60_000} time_remaining={@time_remaining} />
    </div>
    """
  end

  def handle_game_server_msg({:timer_started, expires_at}, socket) do
    {:ok, assign(socket, time_remaining: Timers.time_remaining(expires_at))}
  end
end
