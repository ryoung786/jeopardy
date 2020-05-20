defmodule Jeopardy.FSM.FinalJeopardy.ReadingClue do
  import Ecto.Query, warn: false
  alias Jeopardy.Games.{Game, Player}
  alias Jeopardy.GameState
  alias Jeopardy.Repo


  def handle(_, _, %Game{} = game) do
    GameState.update_round_status(game.code, "reading_clue", "revealing_final_scores")
  end
end
