defmodule JeopardyWeb.TvLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Games
  alias Jeopardy.Games.Game

  @impl true
  def mount(%{"code" => code}, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Jeopardy.PubSub, code)
      Phoenix.PubSub.subscribe(Jeopardy.PubSub, "#{code}-finaljeopardy")
      Phoenix.PubSub.subscribe(Jeopardy.PubSub, "timer:#{code}")
    end

    game = Games.get_by_code(code)
    {:ok, assigns(socket, game)}
  end

  @impl true
  def render(assigns) do
    ~L"""
       <%= live_component(@socket, @component, render_assigns(assigns)) %>
    """
  end

  @impl true
  def handle_event("next", _params, socket) do
    Jeopardy.GameState.update_round_status(
      socket.assigns.game.code,
      "revealing_final_scores",
      "game_over"
    )

    Jeopardy.Stats.update(socket.assigns.game)

    {:noreply, socket}
  end

  def handle_info(%{player: p, step: step}, socket) do
    send_update(
      JeopardyWeb.FinalJeopardyScoreRevealComponent,
      id: 1,
      player_id: p.id,
      step: step
    )

    {:noreply, socket}
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

  def handle_info({:next_category, data}, socket) do
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

  defp assigns(socket, game) do
    clues = %{
      "jeopardy" => Games.clues_by_category(game, :jeopardy),
      "double_jeopardy" => Games.clues_by_category(game, :double_jeopardy)
    }

    socket
    |> assign(game: game)
    |> assign(component: component_from_game(game))
    |> assign(players: Games.get_just_contestants(game))
    |> assign(current_clue: Game.current_clue(game))
    |> assign(clues: clues)
    |> assign(timer: nil)
  end
end
