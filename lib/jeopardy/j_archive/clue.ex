defmodule Jeopardy.JArchive.Clue do
  use Jeopardy.JArchive.Schema
  import Ecto.Changeset

  schema "clues" do
    field :clue_text, :string, size: 512
    field :answer_text, :string
    field :value, :integer
    field :round, :string
    field :type, :string
    field :category, :string
    belongs_to :game, Jeopardy.JArchive.Game

    timestamps()
  end

  @doc false
  def changeset(clue, attrs) do
    clue
    |> cast(attrs, [:clue_text, :answer_text, :value, :type])
    |> validate_required([:clue_text, :answer_text, :value, :round, :type, :category])
  end
end
