defmodule JeopardyWeb.Components.Tv.AwaitingPlayers do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.JArchiveGameLoaded
  alias Jeopardy.FSM.Messages.PlayerAdded
  alias Jeopardy.FSM.Messages.PlayerRemoved
  alias Jeopardy.FSM.Messages.PodiumSigned
  alias Phoenix.LiveView.JS

  def assign_init(socket, game) do
    player_names = game.players |> Map.keys() |> Enum.sort()
    signatures = Map.new(game.players, fn {name, player} -> {name, player.signature} end)

    assign(socket,
      players: player_names,
      original_players: player_names,
      signatures: signatures,
      air_date: game.jarchive_game.air_date
    )
  end

  def handle_game_server_msg(%PlayerRemoved{name: name}, socket) do
    {:ok, assign(socket, players: List.delete(socket.assigns.players, name))}
  end

  def handle_game_server_msg(%PlayerAdded{name: name}, socket) do
    {:ok, assign(socket, players: Enum.sort([name | socket.assigns.players]))}
  end

  def handle_game_server_msg(%PodiumSigned{} = podium, socket) do
    {:ok, assign(socket, signatures: Map.put(socket.assigns.signatures, podium.name, podium.signature))}
  end

  def handle_game_server_msg(%JArchiveGameLoaded{} = game, socket) do
    {:ok, assign(socket, air_date: game.air_date)}
  end

  def handle_event("remove-player", %{"player" => name}, socket) do
    case Jeopardy.GameServer.action(socket.assigns.code, :remove_player, name) do
      {:ok, game} ->
        players = game.players |> Map.keys() |> Enum.sort()

        {:noreply,
         assign(socket,
           original_players: players,
           players: players,
           signatures: Map.delete(socket.assigns.signatures, name)
         )}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("start-game", _, socket) do
    Jeopardy.GameServer.action(socket.assigns.code, :continue)
    {:noreply, socket}
  end

  def handle_event("change-game", _, socket) do
    Jeopardy.GameServer.action(socket.assigns.code, :load_game, :random)
    {:noreply, socket}
  end

  # JS interactions

  defp remove_player(name) do
    "remove-player"
    |> JS.push(value: %{player: name})
    |> hide_modal("remove-modal-#{name}")
    |> JS.hide(
      to: "#podium-#{name}",
      time: 600,
      transition:
        {"transition-all transform ease-out delay-200 duration-[400ms]", "opacity-100 translate-y-0",
         "opacity-0 translate-y-full"}
    )
  end

  defp add_player do
    JS.show(
      time: 400,
      transition:
        {"transition-all transform ease-in duration-[400ms]", "opacity-0 translate-y-full", "opacity-100 translate-y-0"}
    )
  end
end
