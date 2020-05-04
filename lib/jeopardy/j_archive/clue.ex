defmodule Jeopardy.JArchive.Clue do
  use Jeopardy.JArchive.Schema
  import Ecto.Changeset

  schema "clues" do
    field :answer_text, :string
    field :clue_text, :string
    field :type, :string
    field :value, :integer
    belongs_to :category, Jeopardy.JArchive.Category

    timestamps()
  end

  @doc false
  def changeset(clue, attrs) do
    clue
    |> cast(attrs, [:clue_text, :answer_text, :value, :type])
    |> validate_required([:clue_text, :answer_text, :value, :type])
  end
end
