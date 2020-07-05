defmodule Jeopardy.FSM.Jeopardy.RecappingScores do
  use Jeopardy.FSM
  alias Jeopardy.Repo
  alias Jeopardy.Games.{Game, Clue, Player}
  import Ecto.Query

  @impl true
  def handle(:to_double_jeopardy, _, %State{} = state) do
    from(g in Game, where: g.id == ^state.game.id)
    |> Repo.update_all_ts(set: [status: "double_jeopardy", round_status: "revealing_board"])

    {:ok, retrieve_state(state.game.id)}
  end

  @impl true
  def handle(:to_final_jeopardy, _, %State{} = state) do
    final_clue_id = final_jeopardy_clue_id(state.game)
    zero_out_negative_scores(state.game)

    updates = [
      status: "final_jeopardy",
      round_status: "revealing_category",
      current_clue_id: final_clue_id
    ]

    from(g in Game, where: g.id == ^state.game.id)
    |> Repo.update_all_ts(set: updates)

    {:ok, retrieve_state(state.game.id)}
  end

  defp final_jeopardy_clue_id(game) do
    from(c in Clue,
      select: c.id,
      where: c.game_id == ^game.id,
      where: c.round == "final_jeopardy"
    )
    |> Repo.one()
  end

  defp zero_out_negative_scores(game) do
    from(p in Player,
      where: p.game_id == ^game.id,
      where: p.name != ^game.trebek,
      where: p.score <= 0
    )
    |> Repo.update_all_ts(set: [score: 0, final_jeopardy_wager: 0])
  end
end
