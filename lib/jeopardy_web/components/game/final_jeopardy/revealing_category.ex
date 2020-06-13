defmodule JeopardyWeb.Components.Game.FinalJeopardy.RevealingCategory do
  use JeopardyWeb.Components.Base, :game
  require Logger

  @impl true
  def update(%{event: :final_jeopardy_wager, player_wagered: player}, socket) do
    if player.id == socket.assigns.player.id,
      do: {:ok, assign(socket, player: player)},
      else: {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
