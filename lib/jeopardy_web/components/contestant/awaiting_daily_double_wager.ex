defmodule JeopardyWeb.Components.Contestant.AwaitingDailyDoubleWager do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, _game) do
    contestant = socket.assigns.game.contestants[socket.assigns.game.board_control]
    score = contestant.score

    {min_wager, max_wager} =
      if socket.assigns.game.round == :jeopardy,
        do: {5, max(score, 1_000)},
        else: {10, max(score, 2_000)}

    assign(socket,
      has_board_control?: socket.assigns.name == socket.assigns.game.board_control,
      min_wager: min_wager,
      max_wager: max_wager
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <div :if={@has_board_control?}>
        <p>Tell <%= @trebek %> how much you'd like to wager.</p>
        <p>You can wager between $<%= @min_wager %> and $<%= @max_wager %>.</p>
      </div>

      <div :if={not @has_board_control?}>
        <p>
          Waiting for <%= @game.board_control %> to tell <%= @trebek %> how much they'd like to wager.
        </p>
      </div>
    </div>
    """
  end
end
