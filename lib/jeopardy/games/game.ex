defmodule Jeopardy.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :buzzer, :string
    field :code, :string
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:code, :status, :buzzer])
    |> validate_required([:code, :status, :buzzer])
  end
end
