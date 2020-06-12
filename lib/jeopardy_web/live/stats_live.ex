defmodule JeopardyWeb.StatsLive do
  use JeopardyWeb, :live_view
  require Logger
  alias Jeopardy.Games
  alias Jeopardy.Games.Game

  @impl true
  def mount(%{"code" => code}, _session, socket) do
    game = Games.get_by_code(code)
    players = Games.get_just_contestants(game) |> Enum.sort_by(& &1.score, :desc)

    socket =
      assign(socket, game: game)
      |> assign(players: players)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    stats = Cachex.get!(:stats, "game:#{assigns.game.id}") |> Jason.encode!()

    player_ids_to_names =
      Enum.reduce(assigns.players, %{}, fn p, acc ->
        Map.put(acc, Integer.to_string(p.id), p.name)
      end)
      |> Jason.encode!()

    ~L"""
    <script src="https://cdn.jsdelivr.net/npm/chart.js@2.9.3"></script>
    <div style="position: relative" phx-hook="stats">
        <canvas id="stats"></canvas>
    </div>
    <script language="JavaScript">
        const stats = <%= raw(stats) %>;
        const player_ids_to_names = <%= raw(player_ids_to_names) %>;
    --></script>
    """
  end
end
