defmodule JeopardyWeb.Components.Game.PreJeopardy.AwaitingStart do
  use JeopardyWeb.Components.Base, :game
  alias Jeopardy.Games

  @impl true
  def update(%{event: :player_joined, name: name}, socket),
    do: {:ok, assign(socket, audience: socket.assigns.audience ++ [name])}

  @impl true
  def update(%{event: :player_left, name: name}, socket),
    do: {:ok, assign(socket, audience: List.delete(socket.assigns.audience, name))}

  @impl true
  def update(assigns, socket) do
    audience =
      socket.assigns[:audience] || Games.get_all_players(assigns.game) |> Enum.map(& &1.name)

    {:ok,
     assign(socket, assigns)
     |> assign(audience: audience)}
  end
end
