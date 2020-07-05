defmodule Jeopardy.FSM.FinalJeopardy.RevealingCategory do
  use Jeopardy.FSM
  alias Jeopardy.Games.Player

  @impl true
  def handle(:wager, %{player_id: player_id, amount: amount}, %State{} = state) do
    from(p in Player, select: p, where: p.id == ^player_id)
    |> Repo.update_all_ts(set: [final_jeopardy_wager: amount])

    {:ok, retrieve_state(state.game.id)}
  end

  @impl true
  def handle(:trebek_advance, _, %State{} = state) do
    if all_final_jeopardy_wagers_submitted?(state),
      do: {:ok, State.update_round(state, "reading_clue")},
      else: {:ok, state}
  end

  defp all_final_jeopardy_wagers_submitted?(%State{} = state) do
    Enum.all?(state.contestants, fn {_id, p} ->
      not is_nil(p.final_jeopardy_wager)
    end)
  end
end
