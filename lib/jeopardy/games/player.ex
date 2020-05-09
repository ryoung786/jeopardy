defmodule Jeopardy.Games.Player do
  use Jeopardy.Games.Schema
  import Ecto.Changeset

  schema "players" do
    field :name, :string, null: false, size: 25
    field :score, :integer, null: false, default: 0
    field :final_jeopardy_wager, :integer
    field :correct_answers, {:array, :id}
    field :incorrect_answers, {:array, :id}
    belongs_to :game, Jeopardy.Games.Game

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :score])
    |> update_change(:name, &String.trim/1)
    |> validate_required([:name, :game_id])
    |> validate_length(:name, max: 25, message: "Keep it short! 25 letters is the max.")
    |> assoc_constraint(:game)
  end

  def min_max_wagers(%Jeopardy.Games.Player{} = p) do
    min = 5
    max = max(1000, p.score)
    {min, max}
  end
end
