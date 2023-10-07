defmodule JeopardyWeb.Components.Contestant.AwaitingDailyDoubleWager do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    contestant = game.contestants[socket.assigns.name]
    score = contestant.score
    min_wager = if game.round == :jeopardy, do: 5, else: 10

    {:ok,
     assign(socket,
       score: score,
       has_board_control?: socket.assigns.name == game.board.control,
       board_control: game.board.control,
       min_wager: min_wager
     )}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div :if={@has_board_control?}>
        <p>Tell <%= @trebek %> how much you'd like to wager.</p>
        <p>You can wager between $<%= @min_wager %> and $<%= @score %>.</p>
      </div>

      <div :if={not @has_board_control?}>
        <p>Waiting for <%= @board_control %> to tell <%= @trebek %> how much they'd like to wager.</p>
      </div>
    </div>
    """
  end
end
