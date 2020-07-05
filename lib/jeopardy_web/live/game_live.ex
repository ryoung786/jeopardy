defmodule JeopardyWeb.GameLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.GameEngine.State

  @impl true
  def mount(%{"code" => _code}, %{"name" => name, "game" => game}, socket) do
    trebek_name = game.trebek

    case name do
      "" ->
        {:ok, socket |> put_flash(:info, "Please enter a name") |> redirect(to: "/")}

      ^trebek_name ->
        {:ok, redirect(socket, to: "/games/#{game.code}/trebek")}

      _ ->
        if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, "game:#{game.id}")
        {:ok, assigns(socket, game, name)}
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
  def handle_info(_, socket), do: {:noreply, socket}

  defp assigns(socket, %State{} = state, name) do
    {_id, player} = state.contestants |> Enum.find(fn {_k, v} -> v.name == name end)

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

  defp assigns(socket, game, name),
    do: assigns(socket, State.retrieve_state(game.id), name)

  defp can_buzz?(%State{game: game} = state, player) do
    is_nil(game.buzzer_player) && game.buzzer_lock_status == "clear" &&
      state.current_clue &&
      player.id not in state.current_clue.incorrect_players
  end
end
