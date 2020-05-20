defmodule JeopardyWeb.GameLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Games
  alias Jeopardy.Games.Game
  alias Jeopardy.GameState
  alias JeopardyWeb.Presence
  alias JeopardyWeb.GameView
  import Jeopardy.FSM

  @impl true
  def mount(%{"code" => code}, %{"name" => name}, socket) do
    game = Games.get_by_code(code)
    trebek_name = game.trebek
    Presence.track(self(), code, name, %{name: name})
    player = Games.get_player(game, name)

    case name do
      "" -> {:ok, socket |> put_flash(:info, "Please enter a name") |> redirect(to: "/")}
      ^trebek_name ->
        {:ok, redirect(socket, to: "/games/#{game.code}/trebek")}
      _ ->
        if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, code)

        socket = socket
        |> assign(name: name)
        |> assign(game: game)
        |> assign(player: player)
        |> assign(can_buzz: Games.can_buzz?(game, player))
        |> assign(current_clue: Game.current_clue(game))
        |> assign(audience: Presence.list_presences(code))

        {:ok, socket}
    end
  end

  @impl true
  def render(assigns) do
    GameView.render(tpl_path(assigns), assigns)
  end

  @impl true
  def handle_event("volunteer_to_host", _, %{assigns: %{name: name}} = socket) do
    socket.assigns.game
    |> Games.assign_trebek(name)
    {:noreply, socket}
  end

  def handle_event(event, _, %{assigns: %{game: game, name: player_name}} = socket) do
    module = module_from_game(game)
    module.handle(event, player_name, game)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    {:noreply, assign(socket, audience: Presence.list_presences(socket.assigns.game.code))}
  end

  @impl true
  # The db got updated, so let's query for the latest everything
  # and update our assigns
  def handle_info(_, socket) do
    game = game_from_socket(socket)
    name = socket.assigns.name
    player = Games.get_player(game, name)
    case game.trebek do
      ^name -> {:noreply, redirect(socket, to: "/games/#{game.code}/trebek")}
      _ ->
        socket = socket
        |> assign(game: game)
        |> assign(player: player)
        |> assign(can_buzz: Games.can_buzz?(game, player))
        |> assign(players: Games.get_just_contestants(game))
        |> assign(current_clue: Game.current_clue(game))
        {:noreply, socket}
    end
  end
end
