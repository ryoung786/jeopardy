defmodule JeopardyWeb.Components.Tv.AwaitingFinalJeopardyWagers do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    {:ok,
     assign(socket,
       category: List.first(game.board.categories),
       time_left: DateTime.diff(game.fsm.data.expires_at, DateTime.utc_now(), :millisecond)
     )}
  end

  def render(assigns) do
    ~H"""
    <h3><%= @category %></h3>
    """
  end
end
