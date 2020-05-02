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
end
