defmodule Jeopardy.FSM.ReadingDailyDoubleClue do
  @moduledoc """
  reading daily double clue -> selecting clue | recapping round
  """

  use Jeopardy.FSM.State

  alias Jeopardy.Board
  alias Jeopardy.Game

  @impl true
  def valid_actions, do: ~w/answered/a

  @impl true
  def handle_action(:answered, game, correct_or_incorrect), do: answer(game, correct_or_incorrect)

  defp answer(%Game{} = game, response) do
    amount = if response == :correct, do: game.clue.wager, else: -game.clue.wager

    next = if Board.empty?(game.board), do: FSM.RecappingRound, else: FSM.SelectingClue

    {:ok,
     game
     |> Game.update_contestant_score(game.board.control, amount)
     |> FSM.to_state(next)}
  end
end
