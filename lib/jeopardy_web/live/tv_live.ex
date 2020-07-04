defmodule JeopardyWeb.TvLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.GameEngine.State
  alias Jeopardy.Games

  @impl true
  def mount(%{"code" => code}, _session, socket) do
    game = Games.get_by_code(code)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Jeopardy.PubSub, "game:#{game.id}")
      Phoenix.PubSub.subscribe(Jeopardy.PubSub, "#{code}-finaljeopardy")
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

  def handle_info(%State{} = state, socket) do
    {:noreply, assigns(socket, state)}
  end

  def handle_info(%{event: _} = data, socket) do
    component = component_from_game(socket.assigns.game)

    assigns =
      socket.assigns
      |> Map.delete(:flash)
      |> Map.merge(data)
      |> Map.put(:id, Atom.to_string(component))

    send_update(component, assigns)
    {:noreply, socket}
  end

  @impl true
  # The db got updated, so let's query for the latest everything
  # and update our assigns
  def handle_info(_, socket) do
    game = Games.get_by_code(socket.assigns.game.code)
    {:noreply, assigns(socket, game)}
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
