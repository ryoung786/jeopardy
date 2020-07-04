defmodule Jeopardy.FSM.PreJeopardy.IntroducingRoles do
  use Jeopardy.FSM

  def handle(%{event: :next}, %{game: game} = state) do
    with {:ok, game} <-
           Jeopardy.GameState.update_game_status(
             game.code,
             "pre_jeopardy",
             "jeopardy",
             "revealing_board"
           ) do
      Jeopardy.Stats.create(game)
    else
      _ -> state
    end
  end
end
