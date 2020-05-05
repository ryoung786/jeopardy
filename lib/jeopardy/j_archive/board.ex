defmodule Jeopardy.JArchive.Board do
  use Jeopardy.JArchive.Schema
  import Ecto.Changeset

  schema "boards" do
    field :category_array, {:array, :id}, default: []
    belongs_to :show, Jeopardy.JArchive.Show
    has_many :categories, Jeopardy.JArchive.Category

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:category_array])
    |> validate_required([:category_array])
  end
end
