defmodule Jeopardy.Board do
  use TypedStruct

  typedstruct do
    field :control, String.t()
    field :categories, [String.t()], default: []
    field :clues, map(), default: %{}
  end

  alias Jeopardy.JArchive.RecordedGame
  alias Jeopardy.Board.Clue

  @spec from_game(%RecordedGame{}, :jeopardy | :double_jeopardy) :: %Jeopardy.Board{}
  def from_game(%RecordedGame{} = game, round) do
    %__MODULE__{
      categories: Map.get(game.categories, round),
      clues:
        Map.new(Map.get(game, round), fn category ->
          {category.category,
           Map.new(category.clues, fn clue ->
             {clue.value,
              %Clue{
		category: category.category,
                clue: clue.clue,
                answer: clue.answer,
                value: clue.value,
                daily_double?: clue.daily_double?
              }}
           end)}
        end)
    }
  end

  @spec empty?(t()) :: boolean()
  def empty?(%Jeopardy.Board{clues: clues}) do
    clues
    |> Map.values()
    |> Enum.map(&Map.values/1)
    |> List.flatten()
    |> Enum.all?(& &1.asked?)
  end

  def mark_clue_asked(board, category, value) do
    clues = update_in(board.clues, [category, value], fn clue -> %{clue | asked?: true} end)
    %{board | clues: clues}
  end
end
