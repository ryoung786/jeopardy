defmodule Jeopardy.Games.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field :clues, {:array, :id}, default: []
    belongs_to :game, Jeopardy.Games.Board

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:clues])
    |> validate_required([:clues])
  end
end
