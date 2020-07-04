defmodule JeopardyWeb.GameLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Games
  alias Jeopardy.GameEngine.State

  @impl true
  def mount(%{"code" => code}, %{"name" => name}, socket) do
    game = Games.get_by_code(code)
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
  # The db got updated, so let's query for the latest everything
  # and update our assigns
  def handle_info(%State{} = state, socket) do
    Logger.warn("[xxx] got update in GAME")
    name = socket.assigns.name

    if state.trebek && state.trebek.name == name do
      {:noreply, redirect(socket, to: "/games/#{state.game.code}/trebek")}
    else
      {:noreply, assigns(socket, state, name)}
    end
  end

  defp assigns(socket, %State{} = state, name) do
    {_id, player} = state.contestants |> Enum.find(fn {_k, v} -> v.name == name end)

    socket
    |> assign(name: name)
    |> assign(player: player)
    |> assign(can_buzz: Games.can_buzz?(state.game, player))
    |> assign(game: state.game)
    |> assign(component: component_from_game(state.game))
    |> assign(players: state.contestants)
    |> assign(contestants: state.contestants)
    |> assign(current_clue: state.current_clue)
    |> assign(clues: state.clues)
  end

  defp assigns(socket, game, name),
    do: assigns(socket, State.retrieve_state(game.id), name)
end
