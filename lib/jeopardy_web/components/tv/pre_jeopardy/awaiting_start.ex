defmodule JeopardyWeb.Components.TV.PreJeopardy.AwaitingStart do
  use JeopardyWeb.Components.Base, :tv
  alias Jeopardy.GameState

  @impl true
  def handle_event("start_game", _params, socket) do
    # guard if not enough players
    game = Jeopardy.JArchive.load_into_game(socket.assigns.game)
    GameState.update_round_status(game.code, "awaiting_start", "selecting_trebek")
    {:noreply, socket}
  end

  @impl true
  def update(%{event: :player_joined, name: name}, socket),
    do: {:ok, assign(socket, audience: [name | socket.assigns.audience])}

  @impl true
  def update(%{event: :player_left, name: name}, socket),
    do: {:ok, assign(socket, audience: List.delete(socket.assigns.audience, name))}

  @impl true
  def update(assigns, socket), do: {:ok, assign(socket, assigns)}
end
