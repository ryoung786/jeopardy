defmodule JeopardyWeb.GameLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.GameEngine.State
  alias Jeopardy.Games.Player

  @impl true
  def mount(%{"code" => _code}, %{"name" => name, "game" => game}, socket) do
    trebek_name = game.trebek

    case name do
      "" ->
        {:ok, socket |> put_flash(:info, "Please enter a name") |> redirect(to: "/")}

      ^trebek_name ->
        {:ok, redirect(socket, to: "/games/#{game.code}/trebek")}

      _ ->
        state = State.retrieve_state(game.id)
        player = player_from_name(state, name)
        if connected?(socket), do: pubsub_subscribe(game.id, player.id)
        {:ok, assigns(socket, state, name)}
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

    if state.trebek && state.trebek.name == name,
      do: {:noreply, redirect(socket, to: "/games/#{state.game.code}/trebek")},
      else: {:noreply, assigns(socket, state, name)}
  end

  @impl true
  def handle_info({:early_buzz, lock_status}, socket) do
    {:noreply, assign(socket, early_buzz_penalty: lock_status == :locked)}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}

  defp assigns(socket, %State{} = state, name) do
    player = player_from_name(state, name)

    socket
    |> assign(name: name)
    |> assign(player: player)
    |> assign(can_buzz: can_buzz?(state, player))
    |> assign(early_buzz_penalty: Player.buzzer_locked_by_early_buzz?(player.id))
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
    {_id, player} = state.contestants |> Enum.find(fn {_k, v} -> v.name == name end)
    player
  end

  defp pubsub_subscribe(game_id, player_id) do
    Phoenix.PubSub.subscribe(Jeopardy.PubSub, "game:#{game_id}")
    Phoenix.PubSub.subscribe(Jeopardy.PubSub, "player:#{player_id}")
  end
end
