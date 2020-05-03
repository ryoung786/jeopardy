defmodule JeopardyWeb.TrebekLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Games
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
        |> assign(game: game)
        |> assign(is_trebek: name == game.trebek)
        |> assign(audience: Presence.list_presences(code))
        |> assign(buzzer: game.buzzer)
        {:ok, socket}
        _ ->
          {:ok, socket |> put_flash(:info, "Sorry, unauthorized") |> redirect(to: "/")}
    end
  end

  @impl true
  def render(assigns) do
    TrebekView.render("#{assigns.game.status}.html", assigns)
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
  def handle_event("introduce_round_one_categories", _, %{assigns: %{name: name, game: %{code: code}}} = socket) do
    Logger.info("onwards to round one categories")
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
    socket = socket
    |> assign(game: game)
    |> assign(players: Games.get_just_contestants(game))
    {:noreply, socket}
  end
end
