defmodule Jeopardy.FSM.Jeopardy.AwaitingBuzzer do
  use Jeopardy.FSM
  alias Jeopardy.Repo
  alias Jeopardy.Games.{Game, Clue, Player}
  import Ecto.Query

  @impl true
  def on_enter(state) do
    Jeopardy.Timer.start(state.game.code, 5)
    state
  end

  @impl true
  def handle(:buzz, player_id, %State{} = state) do
    buzz(player_id, state)
    {:ok, retrieve_state(state.game.id)}
  end

  @impl true
  def handle(:time_expired, nil, %State{} = state) do
    no_answer(state)
    {:ok, retrieve_state(state.game.id)}
  end

  defp buzz(player_id, state) do
    player = state.contestants[player_id]

    if Player.buzzer_locked_by_early_buzz?(player_id) do
      :failed
    else
      q =
        from g in Game,
          where: g.id == ^state.game.id,
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
          :failed

        {1, _} ->
          Jeopardy.Timer.stop(state.game.code)
          :ok
      end
    end
  end

  defp no_answer(%State{game: game, current_clue: current_clue} = state) do
    num_incorrect_answers = current_clue.incorrect_players |> Enum.count()

    q =
      from g in Game,
        join: c in Clue,
        on: g.current_clue_id == c.id,
        where: g.id == ^game.id,
        where: g.buzzer_lock_status == "clear",
        where: g.round_status == "awaiting_buzzer",
        where: g.current_clue_id == ^game.current_clue_id,
        where:
          fragment("coalesce(array_length(?, 1), 0)", c.incorrect_players) ==
            ^num_incorrect_answers

    updates = [buzzer_player: nil, buzzer_lock_status: "locked", round_status: "revealing_answer"]

    case Repo.update_all_ts(q, set: updates) do
      {0, _} ->
        :failed

      {1, _} ->
        Jeopardy.Timer.stop(state.game.code)
        :ok
    end
  end
end
