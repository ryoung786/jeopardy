defmodule JeopardyWeb.Components.TV.PreJeopardy.AwaitingStart do
  use JeopardyWeb.Components.Base, :tv
  alias Jeopardy.{Games, GameState}

  @impl true
  def handle_event("start_game", _params, socket) do
    x =
      GenServer.cast(
        via_tuple(socket.assigns.game.id),
        %{event: :start_game, data: nil}
      )

    y = Process.whereis(via_tuple(socket.assigns.game.id))
    Logger.warn("[xxx] he #{inspect(x)}")
    Logger.warn("[xxx] y #{inspect(y)}")

    {:noreply, socket}
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
     |> assign(audience: audience)}
  end
end
