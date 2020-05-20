defmodule JeopardyWeb.TrebekLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Games.Game
  alias Jeopardy.Games
  alias Jeopardy.GameState
  alias JeopardyWeb.Presence
  alias JeopardyWeb.TrebekView
  import Jeopardy.FSM

  @impl true
  def mount(%{"code" => code}, %{"name" => name}, socket) do
    game = Games.get_by_code(code)
    Presence.track(self(), code, name, %{name: name})

    case game.trebek do
      ^name ->
        if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, code)
        socket = socket
        |> assign(name: name)
        |> assign(current_clue: Game.current_clue(game))
        |> assign(audience: Presence.list_presences(code))
        |> assigns(game)
        {:ok, socket}
      _ ->
        {:ok, socket |> put_flash(:info, "Sorry, unauthorized") |> redirect(to: "/")}
    end
  end

  @impl true
  def render(assigns) do
    TrebekView.render(tpl_path(assigns), assigns)
  end

  @impl true
  def handle_event(event, data, %{assigns: %{game: game}} = socket) do
    module = module_from_game(socket.assigns.game)
    module.handle(event, data, game)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    {:noreply, assign(socket, audience: Presence.list_presences(socket.assigns.game.code))}
  end

  # @impl true
  # def handle_info(:final_jeopardy_wager_submitted, socket) do
  #   game = game_from_socket(socket)
  #   if Games.all_final_jeopardy_wagers_submitted?(game) do
  #     GameState.update_round_status(game.code, "revealing_category", "reading_clue")
  #   end
  #   {:noreply, socket}
  # end

  @impl true
  def handle_info(%{round_status_change: _}, socket), do: {:noreply, assigns(socket)}
  @impl true
  def handle_info(%{game_status_change: _}, socket), do: {:noreply, assigns(socket)}

  @impl true
  # The db got updated, so let's query for the latest everything
  # and update our assigns
  def handle_info(_, socket), do: {:noreply, assigns(socket)}

  defp assigns(socket) do
    game = Games.get_by_code(socket.assigns.game.code)
    assigns(socket, game)
  end
  defp assigns(socket, %Game{} = game) do
    clues = %{"jeopardy" => Games.clues_by_category(game, :jeopardy),
              "double_jeopardy" => Games.clues_by_category(game, :double_jeopardy)}
    socket
    |> assign(game: game)
    |> assign(clues: clues)
    |> assign(current_clue: Game.current_clue(game))
    |> assign(players: Games.get_just_contestants(game))
  end
end
