defmodule JeopardyWeb.Components.Tv.AwaitingPlayers do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.PlayerAdded
  alias Jeopardy.FSM.Messages.PlayerRemoved
  alias Phoenix.LiveView.JS

  def assign_init(socket, game) do
    assign(socket, players: game.players)
  end

  def handle_game_server_msg(%PlayerRemoved{name: name}, socket) do
    {:ok, assign(socket, players: List.delete(socket.assigns.players, name))}
  end

  def handle_game_server_msg(%PlayerAdded{name: name}, socket) do
    {:ok, assign(socket, players: socket.assigns.players ++ [name])}
  end

  def handle_event("remove-player", %{"player" => player}, socket) do
    case Jeopardy.GameServer.action(socket.assigns.code, :remove_player, player) do
      {:ok, game} -> {:noreply, assign(socket, players: game.players)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("start-game", _, socket) do
    Jeopardy.GameServer.action(socket.assigns.code, :continue)
    {:noreply, socket}
  end

  # JS interactions

  defp remove_player(name) do
    "remove-player"
    |> JS.push(value: %{player: name})
    |> hide_modal("remove-modal-#{name}")
    |> JS.hide(
      to: "#podium-#{name}",
      time: 800,
      transition:
        {"transition-all transform ease-in delay-200 duration-[600ms]", "opacity-100 translate-y-0",
         "opacity-0 translate-y-4"}
    )
  end
end
