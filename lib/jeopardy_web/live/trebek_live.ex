defmodule JeopardyWeb.TrebekLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Games.Game
  alias Jeopardy.Games
  alias Jeopardy.GameState
  alias JeopardyWeb.Presence
  alias JeopardyWeb.TrebekView

  @impl true
  def mount(%{"code" => code}, %{"name" => name}, socket) do
    game = Games.get_by_code(code)
    Presence.track(self(), code, name, %{name: name})

    case game.trebek do
      ^name ->
        if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, code)
        socket = socket
        |> assign(name: name)
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
  def handle_event("buzz", _, %{assigns: %{name: name, game: %{code: code}}} = socket) do
    Logger.info("buzz attempt by #{name}")
    Games.buzzer(code, name)
    {:noreply, socket}
  end

  @impl true
  def handle_event("clear", _, %{assigns: %{name: name, game: %{code: code}}} = socket) do
    Logger.info("#{name} attempted to clear the buzzer")
    Games.clear_buzzer(code)
    {:noreply, socket}
  end

  @impl true
  def handle_event("click_clue", %{"clue_id" => _id}, socket) do
    # Games.set_current_clue(String.to_integer(id))
    {:noreply, socket}
  end

  @impl true
  def handle_event("advance_to_round", _, socket) do
    GameState.update_game_status(socket.assigns.game.code, "pre_jeopardy", "jeopardy", "revealing_board")
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
    {:noreply, assigns(socket)}
  end

  defp assigns(socket) do
    game = Games.get_by_code(socket.assigns.game.code)
    assigns(socket, game)
  end
  defp assigns(socket, %Game{} = game) do
    socket
    |> assign(game: game)
    |> assign(jeopardy_clues: Games.clues_by_category(game, :jeopardy))
    |> assign(double_jeopardy_clues: Games.clues_by_category(game, :double_jeopardy))
    |> assign(players: Games.get_just_contestants(game))
  end
end
