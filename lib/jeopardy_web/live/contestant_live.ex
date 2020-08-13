defmodule JeopardyWeb.ContestantLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.GameEngine.State
  alias Jeopardy.Games.Player

  @impl true
  def mount(%{"code" => _code}, %{"name" => name, "game_id" => game_id}, socket) do
    game = Jeopardy.Games.get_game!(game_id)
    trebek_name = game.trebek

    case name do
      "" ->
        {:ok, socket |> put_flash(:info, "Please enter a name") |> redirect(to: "/")}

      ^trebek_name ->
        {:ok, redirect(socket, to: "/games/#{game.code}/trebek")}

      _ ->
        state = State.retrieve_state(game.id)
        if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, "game:#{game.id}")

        if name in Enum.map(state.contestants, fn {_id, p} -> p.name end),
          do: {:ok, assigns(socket, state, name)},
          else:
            {:ok,
             socket
             |> put_flash(:info, "You were removed from the game by the host")
             |> redirect(to: "/")}
    end
  end

  @impl true
  def render(assigns) do
    ~L"""
       <%= live_component(@socket, @component, render_assigns(assigns)) %>
    """
  end

  @impl true
  def handle_info(%State{} = state, socket) do
    name = socket.assigns.name

    if state.trebek && state.trebek.name == name do
      {:noreply, redirect(socket, to: "/games/#{state.game.code}/trebek")}
    else
      if name in Enum.map(state.contestants, fn {_id, p} -> p.name end),
        do: {:noreply, assigns(socket, state, name)},
        else:
          {:noreply,
           socket
           |> put_flash(:info, "You were removed from the game by the host")
           |> redirect(to: "/")}
    end
  end

  @impl true
  def handle_info(%{event: :next_category} = event, socket) do
    data = Map.put(event, :id, Atom.to_string(socket.assigns.component))
    send_update(socket.assigns.component, data)
    {:noreply, socket}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}

  defp assigns(socket, %State{} = state, name) do
    player = player_from_name(state, name)

    socket
    |> assign(name: name)
    |> assign(player: player)
    |> assign(can_buzz: can_buzz?(state, player))
    |> assign(game: state.game)
    |> assign(component: component_from_game(state.game))
    |> assign(players: state.contestants)
    |> assign(contestants: state.contestants)
    |> assign(current_clue: state.current_clue)
    |> assign(clues: state.clues)
  end

  defp can_buzz?(%State{game: game} = state, %Player{} = player) do
    is_nil(game.buzzer_player) && game.buzzer_lock_status == "clear" &&
      state.current_clue &&
      player.id not in state.current_clue.incorrect_players
  end

  defp player_from_name(%State{} = state, name) do
    with {_id, player} <- state.contestants |> Enum.find(fn {_k, v} -> v.name == name end) do
      player
    else
      _ -> nil
    end
  end
end
