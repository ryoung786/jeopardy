defmodule Jeopardy.FSM.FinalJeopardy.AwaitingAnswers do
  use Jeopardy.FSM
  alias Jeopardy.Games.Player

  @impl true
  def on_enter(state) do
    if all_final_jeopardy_answers_submitted?(state) do
      State.update_round(state, "grading_answers")
    else
      Jeopardy.Timer.start(state.game.code, 60)
      state
    end
  end

  @impl true
  def handle(:time_expired, _, %State{} = state) do
    {:ok, State.update_round(state, "grading_answers")}
  end

  @impl true
  def handle(:answer_submitted, %{player_id: player_id, answer: answer}, %State{} = state) do
    from(p in Player, select: p, where: p.id == ^player_id)
    |> Repo.update_all_ts(set: [final_jeopardy_answer: answer])

    if all_final_jeopardy_answers_submitted?(state) do
      Jeopardy.Timer.stop(state.game.code)
      {:ok, State.update_round(state, "grading_answers")}
    else
      {:ok, retrieve_state(state.game.id)}
    end
  end

  defp all_final_jeopardy_answers_submitted?(%State{} = state) do
    Enum.all?(state.contestants, fn {_id, p} ->
      not is_nil(p.final_jeopardy_answer)
    end)
  end
end
