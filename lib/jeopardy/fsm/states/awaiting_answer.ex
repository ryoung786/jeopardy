defmodule Jeopardy.FSM.AwaitingAnswer do
  @moduledoc """
  awaiting answer -> awaiting buzz | selecting clue | recapping round
  """

  use Jeopardy.FSM.State
  alias Jeopardy.Game
  alias Jeopardy.Board

  @impl true
  def valid_actions(), do: ~w/answered/a

  @impl true
  def handle_action(:answered, game, correct_or_incorrect), do: answer(game, correct_or_incorrect)

  defp answer(game, :correct) do
    {:ok,
     game
     |> Game.update_contestant_score(game.buzzer, game.clue.value)
     |> Map.put(:buzzer, nil)
     |> to_next_state()}
  end

  defp answer(game, :incorrect) do
    incorrect_contestants = [game.buzzer | game.clue.incorrect_contestants]

    game =
      put_in(game.clue.incorrect_contestants, incorrect_contestants)
      |> Game.update_contestant_score(game.buzzer, -1 * game.clue.value)
      |> Map.put(:buzzer, nil)

    # if everybody's tried, go to the next clue, otherwise allow others a chance to buzz
    if Enum.count(incorrect_contestants) >= Enum.count(game.contestants),
      do: {:ok, to_next_state(game)},
      else: {:ok, FSM.to_state(game, FSM.AwaitingBuzz)}
  end

  defp to_next_state(%Game{} = game) do
    next = if Board.empty?(game.board), do: FSM.RecappingRound, else: FSM.SelectingClue
    FSM.to_state(game, next)
  end
end
