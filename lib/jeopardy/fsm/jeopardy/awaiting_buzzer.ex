defmodule Jeopardy.FSM.Jeopardy.AwaitingBuzzer do
  import Ecto.Query, warn: false
  import Jeopardy.FSM
  alias Jeopardy.Games.{Game, Clue, Player}
  alias Jeopardy.Repo

  def handle("buzz", player_name, %Game{} = g) do
    # to: answering_clue
    buzz(g, player_name)
  end

  def handle(:timer_expired, _, %Game{} = g) do
    # to: revealing_answer
    no_answer(g)
  end

  defp buzz(game, player_name) do
    # player = Repo.get!(Player, player_id)
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
        broadcast(game.code, :round_status_change)
        {:ok, nil}
    end
  end

  defp no_answer(%Game{} = game) do
    q =
      from g in Game,
        where: g.id == ^game.id,
        where: g.buzzer_lock_status == "clear",
        where: g.round_status == "awaiting_buzzer"

    updates = [buzzer_player: nil, buzzer_lock_status: "locked", round_status: "revealing_answer"]

    Repo.update_all_ts(q, set: updates)
    broadcast(game.code, :round_status_change)
  end
end
