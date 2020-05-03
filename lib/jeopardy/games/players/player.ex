defmodule Jeopardy.Games.Players.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :name, :string, null: false, size: 25
    field :score, :integer, null: false, default: 0
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
end
