defmodule JeopardyWeb.TvLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Games
  alias Jeopardy.Games.Game
  alias JeopardyWeb.Presence
  alias JeopardyWeb.TvView

  @impl true
  def mount(%{"code" => code}, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, code)

    game = Games.get_by_code(code)
    socket = socket
    |> assigns(game)
    |> assign(audience: Presence.list_presences(code))
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    TvView.render(tpl_path(assigns), assigns)
  end

  @impl true
  def handle_event("start_game", _params, socket) do
    Games.start(socket.assigns.game.code, socket.assigns.audience)
    {:noreply, socket}
  end

  @impl true
  def handle_event("clear", _params, socket) do
    Games.clear_buzzer(socket.assigns.game.code)
    {:noreply, socket}
  end

  @impl true
  def handle_event("trebek_selection", %{"value" => name}, socket) do
    socket.assigns.game
    |> Games.assign_trebek(name)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    {:noreply, assign(socket, audience: Presence.list_presences(socket.assigns.game.code))}
  end

  @impl true
  # The db got updated, so let's query for the latest everything
  # and update our assigns
  def handle_info(_, socket) do
    game = Games.get_by_code(socket.assigns.game.code)
    {:noreply, assigns(socket, game)}
  end

  defp assigns(socket, game) do
    clues = %{"jeopardy" => Games.clues_by_category(game, :jeopardy),
              "double_jeopardy" => Games.clues_by_category(game, :double_jeopardy)}
    socket
    |> assign(game: game)
    |> assign(players: Games.get_just_contestants(game))
    |> assign(current_clue: Game.current_clue(game))
    |> assign(clues: clues)
  end
end
