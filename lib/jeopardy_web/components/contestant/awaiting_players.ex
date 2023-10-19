defmodule JeopardyWeb.Components.Contestant.AwaitingPlayers do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.PlayerAdded
  alias Jeopardy.FSM.Messages.PlayerRemoved

  def assign_init(socket, game) do
    assign(socket, players: game.players)
  end

  def handle_game_server_msg(%PlayerRemoved{name: name}, socket) do
    {:ok, assign(socket, players: List.delete(socket.assigns.players, name))}
  end

  def handle_game_server_msg(%PlayerAdded{name: name}, socket) do
    {:ok, assign(socket, players: socket.assigns.players ++ [name])}
  end
end
