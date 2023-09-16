defmodule Jeopardy.Board do
  defstruct control: nil,
            categories: [],
            clues: %{}

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
             {clue.value, %Clue{clue: clue.clue, answer: clue.answer, asked: false}}
           end)}
        end)
    }
  end

  # defp initial_player_control(%Game{round: :jeopardy} = game) do
  #   Enum.random(game.contestants)
  # end

  # defp initial_player_control(%Game{} = game) do
  #   # If there is a tie for the lowest score, pick one randomly
  #   # So first grab the lowest score
  #   %{score: lowest_score} = Enum.min_by(game.contestants, fn c -> c.score end)

  #   # then choose among players with that score randomly
  #   game.contestants
  #   |> Enum.filter(fn c -> c.score == lowest_score end)
  #   |> Enum.random()
  # end
end
