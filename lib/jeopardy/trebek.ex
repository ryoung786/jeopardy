defmodule Jeopardy.Trebek do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false

  alias Jeopardy.Games.{Game, Clue}
  alias Jeopardy.Games.GameState
  alias Jeopardy.Repo
  alias Jeopardy.GameState

  def select_a_clue(game, clue_id) do
    clue = Repo.get(Clue, clue_id)

    # update the current clue in the db
    game
    |> Game.changeset(%{current_clue: clue_id})
    |> Repo.update()

    # is it a daily double?
    if Clue.is_daily_double(clue) do
      GameState.update_round_status(game.code, "selecting_clue", "awaiting_daily_double_wager")
    else
      GameState.update_round_status(game.code, "selecting_clue", "reading_clue")
    end

  end
end
