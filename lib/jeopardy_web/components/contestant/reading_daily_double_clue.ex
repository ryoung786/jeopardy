defmodule JeopardyWeb.Components.Contestant.ReadingDailyDoubleClue do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    assign(socket,
      has_board_control?: socket.assigns.name == game.board.control,
      board_control: game.board.control,
      wager: game.clue.wager,
      clue: game.clue.clue
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <div :if={@has_board_control?}>
        <h3>For $<%= @wager %>:</h3>
        <p>Tell <%= @trebek %> your answer.</p>
      </div>

      <div :if={not @has_board_control?}>
        <p>Waiting for <%= @board_control %> to answer.</p>
      </div>
    </div>
    """
  end

  def handle_game_server_msg({:revealed_category, index}, socket) do
    {:ok, assign(socket, index: index)}
  end
end
