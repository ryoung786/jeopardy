defmodule Jeopardy.FSM.FinalJeopardy.ReadingClue do
  use Jeopardy.FSM
  alias Jeopardy.Games.Player

  @impl true
  def handle(:trebek_advance, _, %State{} = state),
    do: {:ok, State.update_round(state, "awaiting_answers")}

  @impl true
  def handle(:answer_submitted, %{player_id: player_id, answer: answer}, %State{} = state) do
    from(p in Player, select: p, where: p.id == ^player_id)
    |> Repo.update_all_ts(set: [final_jeopardy_answer: answer])

    {:ok, retrieve_state(state.game.id)}
  end
end
