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

  @impl true
  def handle_event("confirm_remove_player", %{"value" => player_id}, socket) do
    with :ok <- Engine.event(:remove_player, String.to_integer(player_id), socket.assigns.game.id) do
      {:noreply, assign(socket, modal: false)}
    else
      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("maybe_cancel_modal", %{"key" => "Escape"}, socket),
    do: {:noreply, assign(socket, modal: false)}

  @impl true
  def handle_event("maybe_cancel_modal", _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("cancel_remove_player", _params, socket),
    do: {:noreply, assign(socket, modal: false)}

  @impl true
  def handle_event("remove_player_modal_open", %{"name" => name, "id" => id}, socket),
    do: {:noreply, assign(socket, modal: %{player_name: name, player_id: id})}
end
