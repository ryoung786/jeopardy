defmodule JeopardyWeb.Components.Game.PreJeopardy.AwaitingStart do
  use JeopardyWeb.Components.Base, :game
  alias Jeopardy.Games

  @impl true
  def handle_event("signed-podium", params, socket) do
    player = socket.assigns.player
    Cachex.put(:stats, "player-signature:#{player.id}", params["url"], ttl: :timer.hours(48))
    {:noreply, assign(socket, signature: params["url"], editing: false)}
  end

  @impl true
  def handle_event("edit-signature", _params, socket) do
    {:noreply, assign(socket, editing: true)}
  end

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
     |> assign(signature: Cachex.get!(:stats, "player-signature:#{assigns.player.id}"))
     |> assign(audience: audience)}
  end
end
