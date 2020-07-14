defmodule Jeopardy.FSM.Jeopardy.ReadingClue do
  use Jeopardy.FSM
  alias Jeopardy.Repo
  alias Jeopardy.Games.Game
  import Ecto.Query

  @impl true
  def handle(:next, _, %State{} = state) do
    clear_buzzer_and_update_round(state)
    {:ok, retrieve_state(state.game.id)}
  end

  defp clear_buzzer_and_update_round(%State{} = state) do
    updates = [
      buzzer_player: nil,
      buzzer_lock_status: "clear",
      round_status: "awaiting_buzzer"
    ]

    from(g in Game,
      where: g.id == ^state.game.id,
      where: g.round_status == "reading_clue"
    )
    |> Repo.update_all_ts(set: updates)
  end
end
