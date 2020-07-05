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
      Enum.map(socket.assigns.contestants, fn {id, _} -> {id, get_signature(id)} end)
      |> Enum.into(%{})

    socket = assign(socket, signatures: signatures)

    {:ok, socket}
  end

  defp get_signature(player_id),
    do: Cachex.get!(:stats, "player-signature:#{player_id}")
end
