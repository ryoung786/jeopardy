defmodule JeopardyWeb.Components.Game.PreJeopardy.AwaitingStart do
  use JeopardyWeb.Components.Base, :game

  @impl true
  def update(%{event: :player_joined, name: name}, socket),
    do: {:ok, assign(socket, audience: [name | socket.assigns.audience])}

  @impl true
  def update(%{event: :player_left, name: name}, socket),
    do: {:ok, assign(socket, audience: List.delete(socket.assigns.audience, name))}

  @impl true
  def update(assigns, socket), do: {:ok, assign(socket, assigns)}
end
