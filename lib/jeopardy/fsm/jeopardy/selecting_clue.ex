defmodule Jeopardy.FSM.Jeopardy.SelectingClue do
  import Ecto.Query, warn: false
  alias Jeopardy.Games.{Game, Clue}
  alias Jeopardy.GameState
  alias Jeopardy.Repo

  def handle(_, %{"clue_id" => clue_id}, %Game{} = g) do
    set_current_clue(g, clue_id)
    clue = set_clue_to_asked(clue_id)

    case Clue.is_daily_double(clue) do
      true -> daily_double(g)
      _ -> normal(g)
    end
  end

  defp set_current_clue(game, clue_id) do
    Game.changeset(game, %{current_clue_id: clue_id}) |> Repo.update()
  end

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

    Phoenix.PubSub.broadcast(
      Jeopardy.PubSub,
      game.code,
      {:round_status_change, "awaiting_daily_double_wager"}
    )
  end

  defp normal(game) do
    GameState.update_round_status(
      game.code,
      "selecting_clue",
      "reading_clue"
    )
  end
end
