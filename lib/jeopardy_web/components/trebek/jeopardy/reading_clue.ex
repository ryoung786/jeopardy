defmodule JeopardyWeb.Components.Trebek.Jeopardy.ReadingClue do
  use JeopardyWeb, :live_component
  require Logger
  alias Jeopardy.Games.Game
  alias Jeopardy.Repo
  import Ecto.Query

  @impl true
  def render(assigns), do: JeopardyWeb.TrebekView.render(tpl_path(assigns), assigns)

  @impl true
  def handle_event("start_clue_timer", _params, socket) do
    game = socket.assigns.game
    clear_buzzer_and_update_round(game)
    Jeopardy.Timer.start(game.code, 5)
    {:noreply, socket}
  end

  defp clear_buzzer_and_update_round(%Game{} = game) do
    from(g in Game,
      where: g.id == ^game.id,
      where: g.round_status == "reading_clue"
    )
    |> Repo.update_all_ts(
      set: [buzzer_player: nil, buzzer_lock_status: "clear", round_status: "awaiting_buzzer"]
    )

    Phoenix.PubSub.broadcast(
      Jeopardy.PubSub,
      game.code,
      {:round_status_change, "awaiting_buzzer"}
    )
  end
end
