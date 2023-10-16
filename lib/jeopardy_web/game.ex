defmodule JeopardyWeb.Game do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field :code, String.t()
    field :round, :jeopardy | :double_jeopardy | :final_jeopardy, default: :jeopardy
    field :categories, [String.t()]
    field :board, map(), default: %{}
    field :trebek, String.t()
    field :contestants, map(), default: %{}
    field :clue, Clue.t()
    field :buzzer, String.t()
    field :board_control, String.t()
  end

  def new(%Jeopardy.Game{} = game) do
    board =
      Map.new(game.board.categories, fn category ->
        {category,
         Enum.map(game.board.clues[category], fn {_value, clue} ->
           Map.take(clue, [:value, :asked?])
         end)}
      end)

    board = Map.put(board, :categories, game.board.categories)

    game
    |> Map.drop([:players, :jarchive_game, :fsm, :board])
    |> Map.put(:board_control, game.board.control)
    |> Map.put(:categories, game.board.categories)
    |> Map.put(:board, board)
  end
end
