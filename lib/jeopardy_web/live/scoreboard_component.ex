defmodule JeopardyWeb.ScoreboardComponent do
  use JeopardyWeb, :live_component
  alias JeopardyWeb.ScoreboardView
  require Logger

  def render(assigns) do
    ScoreboardView.render("index.html", assigns)
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)

    signatures =
      Enum.reduce(socket.assigns.contestants, %{}, &Map.put(&2, &1.id, get_signature(&1)))

    socket = assign(socket, signatures: signatures)

    {:ok, socket}
  end

  defp get_signature(%Jeopardy.Games.Player{} = player),
    do: Cachex.get!(:stats, "player-signature:#{player.id}")
end
