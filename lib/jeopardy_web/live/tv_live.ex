defmodule JeopardyWeb.TvLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Games
  alias Jeopardy.Games.Game
  alias JeopardyWeb.Presence
  alias JeopardyWeb.TvView
  import Jeopardy.FSM

  @impl true
  def mount(%{"code" => code}, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Jeopardy.PubSub, code)
      Phoenix.PubSub.subscribe(Jeopardy.PubSub, "#{code}-finaljeopardy")
      Phoenix.PubSub.subscribe(Jeopardy.PubSub, "timer:#{code}")
    end

    game = Games.get_by_code(code)

    socket =
      socket
      |> assigns(game)
      |> assign(audience: Presence.list_presences(code))

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    TvView.render(tpl_path(assigns), assigns)
  end

  @impl true
  def handle_event(event, data, socket) do
    module = module_from_game(socket.assigns.game)
    module.handle(event, data, socket.assigns)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    {:noreply, assign(socket, audience: Presence.list_presences(socket.assigns.game.code))}
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

  def handle_info(:timer_expired, socket) do
    module = module_from_game(socket.assigns.game)
    module.handle(:timer_expired, nil, socket.assigns.game)
    {:noreply, assign(socket, timer: :expired)}
  end

  def handle_info({:timer_start, time_left}, socket),
    do: {:noreply, assign(socket, timer: time_left)}

  def handle_info({:timer_tick, time_left}, socket),
    do: {:noreply, assign(socket, timer: time_left)}

  def handle_info(:start, socket) do
    {:noreply, assign(socket, timer: 5)}
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
    |> assign(players: Games.get_just_contestants(game))
    |> assign(current_clue: Game.current_clue(game))
    |> assign(clues: clues)
    |> assign(timer: nil)
  end
end
