defmodule JeopardyWeb.GameLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Games
  alias Jeopardy.Games.Game

  @impl true
  def mount(%{"code" => code}, %{"name" => name}, socket) do
    game = Games.get_by_code(code)
    trebek_name = game.trebek
    player = Games.get_player(game, name)

    case name do
      "" ->
        {:ok, socket |> put_flash(:info, "Please enter a name") |> redirect(to: "/")}

      ^trebek_name ->
        {:ok, redirect(socket, to: "/games/#{game.code}/trebek")}

      _ ->
        if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, code)

        socket =
          socket
          |> assign(name: name)
          |> assign(game: game)
          |> assign(player: player)
          |> assign(component: component_from_game(game))
          |> assign(can_buzz: Games.can_buzz?(game, player))
          |> assign(current_clue: Game.current_clue(game))
          |> assign(audience: Games.get_all_players(game) |> Enum.map(& &1.name))

        {:ok, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~L"""
       <%= live_component(@socket, @component, render_assigns(assigns)) %>
    """
  end

  def handle_info(%{event: _} = data, socket) do
    component = component_from_game(socket.assigns.game)
    send_update(component, Map.put(data, :id, Atom.to_string(component)))
    {:noreply, socket}
  end

  @impl true
  # The db got updated, so let's query for the latest everything
  # and update our assigns
  def handle_info(_, socket) do
    game = game_from_socket(socket)
    name = socket.assigns.name
    player = Games.get_player(game, name)

    case game.trebek do
      ^name ->
        {:noreply, redirect(socket, to: "/games/#{game.code}/trebek")}

      _ ->
        socket =
          socket
          |> assign(game: game)
          |> assign(player: player)
          |> assign(component: component_from_game(game))
          |> assign(can_buzz: Games.can_buzz?(game, player))
          |> assign(players: Games.get_just_contestants(game))
          |> assign(current_clue: Game.current_clue(game))

        {:noreply, socket}
    end
  end
end
