defmodule JeopardyWeb.Components.Game.Jeopardy.AwaitingBuzzer do
  use JeopardyWeb.Components.Base, :game
  require Logger
  alias Jeopardy.Repo
  alias Jeopardy.Games.{Game, Clue, Player}
  import Ecto.Query

  @impl true
  def handle_event("buzz", _params, socket) do
    buzz(socket.assigns.game, socket.assigns.name)
    {:noreply, socket}
  end

  defp buzz(game, player_name) do
    player =
      Repo.one(
        from p in Player, select: p, where: p.game_id == ^game.id, where: p.name == ^player_name
      )

    q =
      from g in Game,
        where: g.id == ^game.id,
        where: g.buzzer_lock_status == "clear",
        where: is_nil(g.buzzer_player),
        where: g.round_status == "awaiting_buzzer",
        join: c in Clue,
        on: c.id == g.current_clue_id,
        on: ^player.id not in c.incorrect_players,
        select: g.id

    updates = [
      buzzer_player: player.name,
      buzzer_lock_status: "player",
      round_status: "answering_clue"
    ]

    case Repo.update_all_ts(q, set: updates) do
      {0, _} ->
        {:failed, nil}

      {1, _} ->
        Jeopardy.Timer.stop(game.code)
        broadcast(game.code)
        {:ok, nil}
    end
  end

  defp broadcast(code) do
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, code, {:round_status_change, "answering_clue"})
  end
end
