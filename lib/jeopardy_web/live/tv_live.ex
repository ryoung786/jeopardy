defmodule JeopardyWeb.TvLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Games

  @impl true
  def mount(%{"code" => code}, _session, socket) do
    Logger.info("MOUNT code #{inspect(code)}")
    if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, code)

    game = Games.get_by_code(code)

    socket = socket
    |> assign(game: game)
    |> assign(buzzer: game.buzzer)

    {:ok, socket}
  end

  @impl true
  def handle_event("start_game", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("clear", _params, socket) do
    Games.clear_buzzer(socket.assigns.game.code)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:buzz, _name}, socket) do
    game = Games.get_by_code(socket.assigns.game.code)
    socket = socket
    |> assign(game: game)
    |> assign(buzzer: game.buzzer)
    {:noreply, socket}
  end

  @impl true
  def handle_info(:clear, socket) do
    game = Games.get_by_code(socket.assigns.game.code)
    socket = socket
    |> assign(game: game)
    |> assign(buzzer: game.buzzer)
    {:noreply, socket}
  end
end
