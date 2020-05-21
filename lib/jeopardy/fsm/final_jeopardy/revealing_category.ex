defmodule Jeopardy.FSM.FinalJeopardy.RevealingCategory do
  import Ecto.Query, warn: false
  import Jeopardy.FSM
  alias Jeopardy.Games.{Game, Player}
  alias Jeopardy.GameState
  alias Jeopardy.Repo

  def handle(_, %{player: player, wager: wager_amount}, %Game{} = game) do
    changeset = Player.changeset(player, %{final_jeopardy_wager: wager_amount})

    with {:ok, _} <- Repo.update(changeset) do
      broadcast(game.code, :final_jeopardy_wager)

      if all_final_jeopardy_wagers_submitted?(game) do
        # start clue timer
        GameState.update_round_status(game.code, "revealing_category", "reading_clue")
      end
    end
  end

  defp all_final_jeopardy_wagers_submitted?(%Game{} = game) do
    num_yet_to_submit =
      from(p in Player,
        select: count(1),
        where: p.game_id == ^game.id,
        where: p.name != ^game.trebek,
        where: is_nil(p.final_jeopardy_wager)
      )
      |> Repo.one()

    num_yet_to_submit == 0
  end
end
