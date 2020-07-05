defmodule JeopardyWeb.TvLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.GameEngine.State
  alias Jeopardy.Games

  @impl true
  def mount(%{"code" => code}, %{"game" => game}, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Jeopardy.PubSub, "game:#{game.id}")
      Phoenix.PubSub.subscribe(Jeopardy.PubSub, "timer:#{code}")
    end

    {:ok, assigns(socket, game)}
  end

  @impl true
  def render(assigns) do
    ~L"""
       <%= live_component(@socket, @component, render_assigns(assigns)) %>
    """
  end

  @impl true
  def handle_info(%State{} = state, socket) do
    Logger.warn("[xxx] got update in TV")
    {:noreply, assigns(socket, state)}
  end

  @impl true
  def handle_info(%{event: :next_category} = event, socket) do
    Logger.warn("[xxx] got next category in TV")
    data = Map.put(event, :id, Atom.to_string(socket.assigns.component))
    send_update(socket.assigns.component, data)
    {:noreply, socket}
  end

  defp assigns(socket, %State{} = state) do
    clues = %{
      "jeopardy" => Games.clues_by_category(state.game, :jeopardy),
      "double_jeopardy" => Games.clues_by_category(state.game, :double_jeopardy)
    }

    socket
    |> assign(game: state.game)
    |> assign(component: component_from_game(state.game))
    |> assign(players: state.contestants)
    |> assign(contestants: state.contestants)
    |> assign(current_clue: state.current_clue)
    |> assign(clues: clues)
    |> assign(timer: nil)
  end

  defp assigns(socket, game),
    do: assigns(socket, State.retrieve_state(game.id))
end
