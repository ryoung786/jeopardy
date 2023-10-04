defmodule JeopardyWeb.Components.Contestant.SelectingClue do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    assign(socket,
      has_board_control?: game.board.control == socket.assigns.name,
      board_control: game.board.control
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <div :if={@has_board_control?}>
        <h3>You have control of the board.</h3>
        <p>Tell <%= @trebek %> which clue you select.</p>
      </div>
      <div :if={!@has_board_control?}>
        <p>Waiting for <%= @board_control %> to select a clue.</p>
      </div>
    </div>
    """
  end

  def handle_game_server_msg({:revealed_category, index}, socket) do
    {:ok, assign(socket, index: index)}
  end
end
