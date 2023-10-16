defmodule JeopardyWeb.Components.Contestant.ReadingDailyDoubleClue do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def assign_init(socket, _game) do
    assign(socket,
      has_board_control?: socket.assigns.name == socket.assigns.game.board_control,
      board_control: socket.assigns.game.board_control,
      wager: socket.assigns.game.clue.wager,
      clue: socket.assigns.game.clue.clue
    )
  end

  def render(assigns) do
    ~H"""
    <div class="w-screen h-screen">
      <.instructions>
        <%= if @has_board_control? do %>
          For $<%= @wager %>:<br /> Tell <%= @game.trebek %> your answer.
        <% else %>
          Waiting for <%= @game.board_control %> to answer.
        <% end %>
      </.instructions>
    </div>
    """
  end

  def handle_game_server_msg({:revealed_category, index}, socket) do
    {:ok, assign(socket, index: index)}
  end
end
