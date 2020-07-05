defmodule Jeopardy.FSM.Jeopardy.AwaitingDailyDoubleWager do
  use Jeopardy.FSM
  alias Jeopardy.Repo
  alias Jeopardy.Games.Clue

  @impl true
  def handle(:wager, %{amount: amount}, %State{} = state) do
    Clue.changeset(state.current_clue, %{wager: amount}) |> Repo.update()
    {:ok, State.update_round(state, "reading_daily_double")}
  end
end
