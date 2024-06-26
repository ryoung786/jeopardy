defmodule JeopardyWeb.Components.Tv.AwaitingPlayers do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.JArchiveGameLoaded
  alias Jeopardy.FSM.Messages.PlayerAdded
  alias Jeopardy.FSM.Messages.PlayerRemoved
  alias Jeopardy.FSM.Messages.PodiumSigned
  alias Jeopardy.JArchive
  alias Phoenix.LiveView.JS

  def assign_init(socket, game) do
    player_names = game.players |> Map.keys() |> Enum.sort()
    signatures = Map.new(game.players, fn {name, player} -> {name, player.signature} end)

    assign(socket,
      players: player_names,
      original_players: player_names,
      signatures: signatures,
      air_date: game.jarchive_game.air_date,
      difficulty_levels: ["easy", "normal", "hard", "very_hard"],
      filters: %{decades: [], difficulty: []}
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

  def handle_game_server_msg(_, socket), do: {:ok, socket}

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
    filters = Map.reject(socket.assigns.filters, fn {_k, v} -> Enum.empty?(v) end)

    case JArchive.choose_game(Map.to_list(filters)) do
      {:ok, game_id} ->
        Jeopardy.GameServer.action(socket.assigns.code, :load_game, game_id)
        {:noreply, socket}

      {:error, "No games exist"} ->
        # There are no "Very Hard" games in the 80s or 90s.
        # To fix, automatically add "Hard" to the difficulty filters and try again

        filters = %{
          decades: socket.assigns.filters.decades,
          difficulty: ["hard" | socket.assigns.filters.difficulty]
        }

        {:ok, game_id} = JArchive.choose_game(Map.to_list(filters))
        Jeopardy.GameServer.action(socket.assigns.code, :load_game, game_id)
        {:noreply, assign(socket, filters: filters)}
    end
  end

  def handle_event("filters-changed", params, socket) do
    filters = %{
      decades: params |> Map.get("decades", []) |> Enum.map(&String.to_integer/1),
      difficulty: Map.get(params, "difficulty", [])
    }

    {:noreply, assign(socket, filters: filters)}
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
