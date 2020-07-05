defmodule Jeopardy.FSM.FinalJeopardy.GradingAnswers do
  use Jeopardy.FSM
  alias Jeopardy.Games.{Player, Clue}

  @impl true
  def handle(:trebek_submit_grades, grades, %State{} = state) do
    Enum.each(state.contestants, fn {player_id, c} ->
      if grades[player_id],
        do: correct(c, state),
        else: incorrect(c, state)
    end)

    {:ok, State.update_round(state, "revealing_final_scores")}
  end

  defp correct(%Player{} = player, state) do
    from(c in Clue, where: c.id == ^state.current_clue.id)
    |> Repo.update_all_ts(push: [correct_players: player.id], set: [id: state.current_clue.id])

    from(p in Player, where: p.id == ^player.id)
    |> Repo.update_all_ts(
      inc: [score: player.final_jeopardy_wager],
      push: [correct_answers: state.current_clue.id],
      set: [final_jeopardy_score_updated: true]
    )
  end

  defp incorrect(%Player{} = player, state) do
    from(c in Clue, where: c.id == ^state.current_clue.id)
    |> Repo.update_all_ts(push: [incorrect_players: player.id], set: [id: state.current_clue.id])

    from(p in Player, where: p.id == ^player.id)
    |> Repo.update_all_ts(
      inc: [score: -1 * player.final_jeopardy_wager],
      push: [incorrect_answers: state.current_clue.id],
      set: [final_jeopardy_score_updated: true]
    )
  end
end
