defmodule Jeopardy.FSM.Jeopardy.AnsweringClue do
  alias Jeopardy.Games
  alias Jeopardy.Games.Game
  alias Jeopardy.GameState

  def handle("correct", _, %Game{} = g) do
    {:ok, g} = Games.correct_answer(g)
    |> Games.lock_buzzer()
    |> Games.assign_board_control(g.buzzer_player)
    GameState.to_selecting_clue(g)
  end

  def handle("incorrect", _, %Game{} = g) do
    Games.incorrect_answer(g)
  end
end
