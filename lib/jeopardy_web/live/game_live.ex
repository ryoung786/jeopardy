defmodule JeopardyWeb.GameLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Games
  alias JeopardyWeb.Presence
  alias JeopardyWeb.GameView

  @impl true
  def mount(%{"code" => code}, %{"name" => name}, socket) do
    game = Games.get_by_code(code)

    Presence.track(
      self(),
      code,
      name,
      %{name: name}
    )

    case name do
      "" -> {:ok, socket |> put_flash(:info, "Please enter a name") |> redirect(to: "/")}
      _ ->
        if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, code)

        socket = socket
        |> assign(name: name)
        |> assign(game: game)
        |> assign(audience: Presence.list_presences(code))
        |> assign(buzzer: game.buzzer)

        {:ok, socket}
    end
  end

  @impl true
  def render(assigns) do
    GameView.render("#{assigns.game.status}.html", assigns)
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
  def handle_info({:buzz, name}, socket) do
    Logger.info("#{name} buzzed in")
    {:noreply, update(socket, :buzzer, fn _ -> name end)}
  end

  @impl true
  def handle_info(:clear, socket) do
    Logger.info("successfully cleared the buzzer")
    {:noreply, update(socket, :buzzer, fn _ -> nil end)}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: _payload}, socket) do
    {:noreply, assign(socket, audience: Presence.list_presences(socket.assigns.game.code))}
  end

  @impl true
  def handle_info(:game_status_change, socket) do
    game = Games.get_by_code(socket.assigns.game.code)
    socket = socket
    |> assign(game: game)
    {:noreply, socket}
  end
end
