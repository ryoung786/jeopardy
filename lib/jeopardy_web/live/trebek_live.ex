defmodule JeopardyWeb.TrebekLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Games.Game
  alias Jeopardy.GameEngine.State

  @impl true
  def mount(%{"code" => _code}, %{"name" => name, "game" => game}, socket) do
    case game.trebek do
      ^name ->
        if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, "game:#{game.id}")

        socket =
          socket
          |> assign(name: name)
          |> assigns(game)

        {:ok, socket}

      _ ->
        {:ok, socket |> put_flash(:info, "Sorry, unauthorized") |> redirect(to: "/")}
    end
  end

  @impl true
  def render(assigns) do
    ~L"""
       <%= live_component(@socket, @component, render_assigns(assigns)) %>
    """
  end

  @impl true
  def handle_info(%State{} = state, socket), do: {:noreply, assigns(socket, state)}
  @impl true
  def handle_info(_, socket), do: {:noreply, socket}

  defp assigns(socket, %Game{} = game), do: assigns(socket, State.retrieve_state(game.id))

  defp assigns(socket, %State{} = state) do
    socket
    |> assign(game: state.game)
    |> assign(component: component_from_game(state.game))
    |> assign(categories: categories(state.game))
    |> assign(clues: clues_by_category(state.game))
    |> assign(current_clue: state.current_clue)
    |> assign(players: state.contestants)
    |> assign(contestants: state.contestants)
    |> assign(trebek: state.trebek)
  end

  defp clues_by_category(%Game{} = game) do
    game.clues
    |> Enum.filter(fn c -> c.round == game.status end)
    |> Enum.group_by(fn c -> c.category end)
    |> Enum.map(fn {k, v} -> {k, Enum.sort_by(v, & &1.value)} end)
    |> Enum.into(%{})
  end

  defp categories(%Game{} = game) do
    if game.status == "jeopardy",
      do: game.jeopardy_round_categories,
      else: game.double_jeopardy_round_categories
  end
end
