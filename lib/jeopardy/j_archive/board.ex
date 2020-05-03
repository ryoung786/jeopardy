defmodule Jeopardy.JArchive.Board do
  use Jeopardy.JArchive.Schema
  import Ecto.Changeset

  schema "boards" do
    field :categories, {:array, :id}, default: []
    belongs_to :game, Jeopardy.Games.Game

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:categories])
    |> validate_required([:categories])
  end
end
