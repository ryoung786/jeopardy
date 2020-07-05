defmodule Jeopardy.FSM.Jeopardy.AnsweringClue do
  use Jeopardy.FSM
  alias Jeopardy.Repo
  alias Jeopardy.Games.{Game, Clue, Player}
  import Ecto.Query

  @impl true
  def handle(:correct, nil, %State{} = state) do
    correct(state)
    {:ok, retrieve_state(state.game.id)}
  end

  @impl true
  def handle(:incorrect, nil, %State{} = state) do
    incorrect(state)
    {:ok, retrieve_state(state.game.id)}
  end

  defp correct(%State{game: game} = state) do
    player_id = player_id_that_buzzed(state)

    # record player correctly answered clue and update clue's status
    from(c in Clue, where: c.id == ^game.current_clue_id)
    |> Repo.update_all_ts(push: [correct_players: player_id], set: [asked_status: "asked"])

    # increase score of buzzer player by current clue value
    amount =
      if Clue.is_daily_double(state.current_clue),
        do: state.current_clue.wager,
        else: state.current_clue.value

    from(p in Player, select: p, where: p.id == ^player_id)
    |> Repo.update_all_ts(
      inc: [score: amount],
      push: [correct_answers: game.current_clue_id],
      set: [id: player_id]
    )

    game_updates = [round_status: "selecting_clue", board_control: game.buzzer_player]

    from(g in Game, where: g.id == ^game.id)
    |> Repo.update_all_ts(set: game_updates)

    Jeopardy.Stats.update(game)
  end

  defp incorrect(%State{game: game} = state) do
    player_id = player_id_that_buzzed(state)

    # record player correctly answered clue and update clue's status
    from(c in Clue, where: c.id == ^game.current_clue_id)
    |> Repo.update_all_ts(push: [incorrect_players: player_id], set: [asked_status: "asked"])

    # decrease score of buzzer player by current clue value
    amount =
      if Clue.is_daily_double(state.current_clue),
        do: state.current_clue.wager,
        else: state.current_clue.value

    from(p in Player, select: p, where: p.id == ^player_id)
    |> Repo.update_all_ts(
      inc: [score: -1 * amount],
      push: [incorrect_answers: game.current_clue_id],
      set: [id: player_id]
    )

    if Clue.is_daily_double(state.current_clue) do
      reveal_answer(state)
    else
      if contestants_remaining?(state),
        do: try_again(state),
        else: reveal_answer(state)
    end
  end

  defp player_id_that_buzzed(%State{game: game, contestants: contestants}) do
    {player_id, _} = contestants |> Enum.find(fn {_, p} -> p.name == game.buzzer_player end)
    player_id
  end

  defp reveal_answer(%State{game: game}) do
    updates = [
      buzzer_player: nil,
      buzzer_lock_status: "locked",
      round_status: "revealing_answer"
    ]

    from(g in Game, where: g.id == ^game.id)
    |> Repo.update_all_ts(set: updates)
  end

  defp try_again(%State{game: game}) do
    updates = [
      buzzer_player: nil,
      buzzer_lock_status: "clear",
      round_status: "awaiting_buzzer"
    ]

    from(g in Game, where: g.id == ^game.id)
    |> Repo.update_all_ts(set: updates)
  end

  defp contestants_remaining?(%{current_clue: clue, contestants: contestants}) do
    num_wrong = Enum.count(clue.incorrect_players) - 1
    Enum.count(contestants) > num_wrong
  end
end
