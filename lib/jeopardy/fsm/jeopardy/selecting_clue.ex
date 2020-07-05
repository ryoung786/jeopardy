defmodule Jeopardy.FSM.Jeopardy.SelectingClue do
  use Jeopardy.FSM
  alias Jeopardy.Repo
  alias Jeopardy.Games.{Game, Clue}
  import Ecto.Query

  @impl true
  def handle(:clue_selected, clue_id, %State{} = state) do
    set_current_clue(state.game, clue_id)
    clue = set_clue_to_asked(clue_id)

    case Clue.is_daily_double(clue) do
      true -> {:ok, daily_double(state.game)}
      _ -> {:ok, normal(state)}
    end
  end

  defp set_current_clue(game, clue_id),
    do: Game.changeset(game, %{current_clue_id: clue_id}) |> Repo.update()

  defp set_clue_to_asked(clue_id) do
    {1, [clue | _]} =
      from(c in Clue, select: c, where: c.id == ^clue_id)
      |> Repo.update_all_ts(set: [asked_status: "asked"])

    clue
  end

  defp daily_double(game) do
    q =
      from g in Game,
        where: g.id == ^game.id,
        where: g.round_status == "selecting_clue"

    updates = [round_status: "awaiting_daily_double_wager", buzzer_player: game.board_control]
    Repo.update_all_ts(q, set: updates)
    retrieve_state(game.id)
  end

  defp normal(state), do: State.update_round(state, "reading_clue")
end
