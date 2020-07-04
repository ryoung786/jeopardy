defmodule JeopardyWeb.Components.TV.PreJeopardy.AwaitingStart do
  use JeopardyWeb.Components.Base, :tv
  alias Jeopardy.GameEngine, as: Engine

  @impl true
  def handle_event("start_game", _params, socket) do
    with :ok <- Engine.event(:start_game, socket.assigns.game.id) do
      {:noreply, socket}
    else
      _ ->
        # live flash?
        {:noreply, socket}
    end
  end
end
