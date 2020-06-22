defmodule JeopardyWeb.Components.TV.FinalJeopardy.RevealingFinalScores do
  use JeopardyWeb.Components.Base, :tv

  @impl true
  def mount(socket) do
    {:ok, assign(socket, signatures: [])}
  end

  @impl true
  def handle_event("game_over", _params, socket) do
    Jeopardy.GameState.update_round_status(
      socket.assigns.game.code,
      "revealing_final_scores",
      "game_over"
    )

    Jeopardy.Stats.update(socket.assigns.game)

    {:noreply, socket}
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)
    signatures = Enum.reduce(socket.assigns.players, %{}, &Map.put(&2, &1.id, get_signature(&1)))
    {:ok, assign(socket, signatures: signatures)}
  end

  defp get_signature(%Jeopardy.Games.Player{} = player),
    do: Cachex.get!(:stats, "player-signature:#{player.id}")
end
