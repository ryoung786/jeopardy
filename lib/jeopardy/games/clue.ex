defmodule Jeopardy.Games.Clue do
  use Jeopardy.Games.Schema
  import Ecto.Changeset


  schema "clues" do
    field :category, :string
    field :clue_text, :string
    field :answer_text, :string
    field :value, :integer, default: 0
    field :round, :string
    field :type, :string
    field :asked_status, :string, default: "unasked"
    field :wager, :integer
    field :incorrect_players, {:array, :id}
    field :correct_players, {:array, :id}
    belongs_to :game, Jeopardy.Games.Game

    timestamps()
  end

  @doc false
  def changeset(clue, attrs) do
    clue
    |> cast(attrs, [:category, :clue_text, :answer_text, :value,
                   :round, :type, :asked_status, :wager,
                   :incorrect_players, :correct_players])
    |> validate_required([:clue_text, :answer_text, :type, :asked_status])
  end
end
