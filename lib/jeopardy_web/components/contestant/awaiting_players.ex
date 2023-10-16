defmodule JeopardyWeb.Components.Contestant.AwaitingPlayers do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    assign(socket, players: game.players)
  end

  def handle_game_server_msg({:player_removed, name}, socket) do
    {:ok, assign(socket, players: List.delete(socket.assigns.players, name))}
  end

  def handle_game_server_msg({:player_added, name}, socket) do
    {:ok, assign(socket, players: socket.assigns.players ++ [name])}
  end
end
