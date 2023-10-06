defmodule JeopardyWeb.Components.Tv.AwaitingFinalJeopardyWagers do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.Timers

  def assign_init(socket, game) do
    {:ok,
     assign(socket,
       category: List.first(game.board.categories),
       time_remaining: Timers.time_remaining(game.fsm.data[:expires_at])
     )}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3><%= @category %></h3>
      <.pie_timer time_remaining={@time_remaining} />
    </div>
    """
  end
end
