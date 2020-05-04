defmodule Jeopardy.JArchive.Category do
  use Jeopardy.JArchive.Schema
  import Ecto.Changeset

  schema "categories" do
    field :name, :string
    field :clue_array, {:array, :id}, default: []
    belongs_to :board, Jeopardy.JArchive.Board
    has_many :clues, Jeopardy.JArchive.Clue

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:clue_array])
    |> validate_required([:clue_array])
  end
end
