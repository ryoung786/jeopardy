defmodule JeopardyWeb.General.StatsComponent do
  use Phoenix.LiveComponent
  alias Jeopardy.{Games, Stats}
  require Logger

  @impl true
  def render(assigns) do
    ~L"""
    <div class="stats" phx-hook="stats">
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
  def update(%{event: :stats_update}, socket) do
    stats = Cachex.get!(:stats, Stats.key(socket.assigns.game))
    {:ok, assign(socket, stats: stats)}
  end

  @impl true
  def update(assigns, socket) do
    stats = Cachex.get!(:stats, Stats.key(assigns.game))

    socket =
      assign(socket, assigns)
      |> assign(stats: stats)

    {:ok, socket}
  end
end
