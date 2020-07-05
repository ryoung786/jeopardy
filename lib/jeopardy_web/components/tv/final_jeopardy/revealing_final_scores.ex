defmodule JeopardyWeb.Components.TV.FinalJeopardy.RevealingFinalScores do
  use JeopardyWeb.Components.Base, :tv

  @impl true
  def mount(socket) do
    {:ok, assign(socket, signatures: [])}
  end

  @impl true
  def handle_event("game_over", _params, socket) do
    Engine.event(:reveal_complete, socket.assigns.game.id)
    {:noreply, socket}
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)

    signatures =
      Enum.reduce(socket.assigns.players, %{}, fn {player_id, player}, acc ->
        Map.put(acc, player_id, get_signature(player))
      end)

    {:ok, assign(socket, signatures: signatures)}
  end

  defp get_signature(%Jeopardy.Games.Player{} = player),
    do: Cachex.get!(:stats, "player-signature:#{player.id}")
end
