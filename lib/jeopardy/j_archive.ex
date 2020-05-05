defmodule Jeopardy.JArchive do
  @moduledoc """
  The JArchive context.
  """

  import Ecto.Query, warn: false
  alias Jeopardy.Repo
  alias Jeopardy.JArchive.{Show, Board, Category, Clue}

  def random_game() do
    Repo.get(Show, 2)
  end

  def board(%Show{} = game) do
    from(b in Board, where: b.game_id == ^game.id) |> Repo.one
  end

  def categories(%Board{} = board) do
    from(c in Category, where: c.board_id == ^board.id) |> Repo.all
  end

  def clues(%Category{} = category) do
    from(c in Clue, where: c.category_id == ^category.id, order_by: [asc: c.value]) |> Repo.all
  end
end
