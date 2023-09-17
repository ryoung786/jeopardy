defmodule Jeopardy.FSM.ReadingDailyDoubleClue do
  @moduledoc """
  reading daily double clue -> selecting clue | recapping round
  """

  use Jeopardy.FSM.State
  alias Jeopardy.Game
  alias Jeopardy.Board

  @impl true
  def valid_actions(), do: ~w/answered/a

  @impl true
  def handle_action(:answered, game, correct_or_incorrect), do: answer(game, correct_or_incorrect)

  defp answer(%Game{} = game, response) do
    amount = if response == :correct, do: game.clue.wager, else: -game.clue.wager

    {:ok,
     game
     |> Game.update_contestant_score(game.board.control, amount)
     |> to_next_state()}
  end

  defp to_next_state(%Game{} = game) do
    next = if Board.empty?(game.board), do: FSM.RecappingRound, else: FSM.SelectingClue
    FSM.to_state(game, next)
  end
end
