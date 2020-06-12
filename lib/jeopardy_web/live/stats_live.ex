defmodule JeopardyWeb.StatsLive do
  use JeopardyWeb, :live_view
  alias Jeopardy.Games
  require Logger

  @impl true
  def mount(%{"code" => code}, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, code)

    game = Games.get_by_code(code)
    stats = Cachex.get!(:stats, "game:#{game.id}")

    socket =
      assign(socket, game: game)
      |> assign(stats: stats)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div phx-hook="stats">
        <script src="https://cdn.jsdelivr.net/npm/chart.js@2.9.3"></script>
        <div id="canvas-holder-score-over-time" style="position: relative" phx-update="ignore">
            <canvas id="stats"></canvas>
        </div>
        <script language="JavaScript" id="js-stats-data"
                data-stats="<%= Jason.encode!(@stats) %>">
        </script>
    </div>
    """
  end

  @impl true
  def handle_info(%{event: :stats_update, payload: payload}, socket) do
    stats = Cachex.get!(:stats, "game:#{payload.game_id}")

    {:noreply, assign(socket, stats: stats)}
  end

  @impl true
  def handle_info(_, socket), do: {:noreply, socket}
end
