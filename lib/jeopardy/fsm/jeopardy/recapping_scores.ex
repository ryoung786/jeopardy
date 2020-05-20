defmodule Jeopardy.FSM.Jeopardy.RecappingScores do
  import Ecto.Query, warn: false
  alias Jeopardy.Games.{Game, Player, Clue}
  alias Jeopardy.GameState
  alias Jeopardy.Repo

  def handle(_, _, %Game{} = g) do
    case g.status do
      "jeopardy" -> GameState.update_game_status(g.code, "jeopardy", "double_jeopardy", "revealing_board")
      "double_jeopardy" ->
        set_final_jeopardy_clue(g)
        zero_out_negative_scores(g)
        # TODO start wager timer
        GameState.update_game_status(g.code, "double_jeopardy", "final_jeopardy", "revealing_category")
    end
  end

  defp set_final_jeopardy_clue(game) do
    clue_id = (from c in Clue,
      select: c.id,
      where: c.game_id == ^game.id, where: c.round == "final_jeopardy"
    ) |> Repo.one()
    Game.changeset(game, %{current_clue_id: clue_id}) |> Repo.update()
  end

  defp zero_out_negative_scores(game) do
    (from p in Player,
      where: p.game_id == ^game.id,
      where: p.name != ^game.trebek,
      where: p.score < 0
    ) |> Repo.update_all_ts(set: [score: 0])
  end
end
