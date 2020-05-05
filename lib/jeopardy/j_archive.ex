defmodule Jeopardy.JArchive do
  @moduledoc """
  The JArchive context.
  """

  import Ecto.Query, warn: false
  alias Jeopardy.Repo
  alias Jeopardy.JArchive.{Game, Clue}

  def random_game() do
    # we use the count of the number of valid games to create a random offset
    num_games = (from g in Game, select: count(g.id), where: not is_nil(g.final_jeopardy_category)) |> Repo.one()
    offset = :rand.uniform(num_games)-1
    (from g in Game, where: not is_nil(g.final_jeopardy_category), offset: ^offset, limit: 1) |> Repo.one()
  end

  def specific_game(id), do: Repo.get!(Game, id)

  def clues_by_category(%Game{} = game, round) when round in [:jeopardy, :double_jeopardy] do
    clues = from(c in Clue,
      where: c.game_id == ^game.id,
      where: c.round == ^Atom.to_string(round),
      order_by: [asc: c.value])
      |> Repo.all
    Enum.map(game.jeopardy_round_categories, fn category ->
      [category: category,
       clues: clues |> Enum.filter(fn clue -> clue.category == category end)]
    end)
  end

  def final_jeopardy_clue(%Game{} = game) do
    from(c in Clue,
      where: c.game_id == ^game.id,
      where: c.round == "final_jeopardy")
    |> Repo.one
  end
end
