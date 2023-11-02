defmodule JeopardyWeb.Components.Contestant.AwaitingPlayers do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.GameServer

  def assign_init(socket, game) do
    assign(socket, signature: game.players[socket.assigns.name].signature)
  end

  def handle_event("signature-changed", %{"signature" => signature}, socket) do
    GameServer.action(socket.assigns.code, :signed_podium, {socket.assigns.name, signature})
    {:noreply, assign(socket, signature: signature)}
  end
end
