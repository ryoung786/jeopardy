defmodule JeopardyWeb.Components.Contestant.SelectingClue do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    assign(socket,
      has_board_control?: socket.assigns.game.board_control == socket.assigns.name,
      board_control: game.board.control
    )
  end

  def render(assigns) do
    ~H"""
    <div class="w-screen h-screen">
      <.instructions>
        <%= if @has_board_control? do %>
          You have control of the board.<br /> Tell <%= @trebek %> which clue you select.
        <% else %>
          Waiting for <%= @game.board_control %> to select a clue.
        <% end %>
      </.instructions>
    </div>
    """
  end
end
