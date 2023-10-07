defmodule Jeopardy.FSM.SelectingClue do
  @moduledoc """
  selecting clue -> awaiting daily double wager | reading clue
  """

  use Jeopardy.FSM.State
  alias Jeopardy.Game
  alias Jeopardy.Board
  alias Jeopardy.Board.Clue

  @impl true
  def valid_actions(), do: ~w/clue_selected/a

  @impl true
  def handle_action(:clue_selected, game, {category, value}),
    do: select_clue(game, category, value)

  def select_clue(%Game{} = game, category, value) do
    case game.board.clues |> Map.get(category, %{}) |> Map.get(value) do
      %Clue{asked?: true} ->
        {:error, :clue_already_asked}

      %Clue{daily_double?: true} = clue ->
        {:ok,
         game
         |> Map.put(:clue, clue)
         |> Map.put(:board, Board.mark_clue_asked(game.board, category, value))
         |> FSM.to_state(FSM.AwaitingDailyDoubleWager)}

      clue ->
        {:ok,
         game
         |> Map.put(:clue, clue)
         |> Map.put(:board, Board.mark_clue_asked(game.board, category, value))
         |> FSM.to_state(FSM.ReadingClue)}
    end
  end
end
