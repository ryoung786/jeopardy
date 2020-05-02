defmodule JeopardyWeb.TvLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Cache, as: Games

  @impl true
  def mount(%{"code" => code}, _session, socket) do
    Logger.info("MOUNT code #{inspect(code)}")
    if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, code)

    game = Games.find(code)

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
  def handle_info({:buzz, name}, socket) do
    Logger.info("#{name} buzzed in")
    Logger.info("BROADCAST RECEIVED handle_info #{name}")
    {:noreply, update(socket, :buzzer, fn _ -> name end)}
  end

  @impl true
  def handle_info(:clear, socket) do
    Logger.info("successfully cleared the buzzer")
    {:noreply, update(socket, :buzzer, fn _ -> :clear end)}
  end
end
