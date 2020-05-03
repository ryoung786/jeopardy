defmodule Jeopardy.Games.Clue do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clues" do
    field :value, :integer, default: 0
    field :answer_text, :string
    field :clue_text, :string
    field :status, :string
    field :type, :string
    belongs_to :game, Jeopardy.Games.Category

    timestamps()
  end

  @doc false
  def changeset(clue, attrs) do
    clue
    |> cast(attrs, [:clue_text, :answer_text, :value, :type, :status])
    |> validate_required([:clue_text, :answer_text, :value, :type, :status])
  end
end
