defmodule Jeopardy.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :buzzer, :string
    field :code, :string, null: false, size: 4
    field :status, :string, default: "start"

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:code, :status, :buzzer])
    |> update_change(:code, &String.upcase/1)
    |> unique_constraint(:code)
    |> validate_required([:code, :status])
    |> validate_format(:code, ~r/[A-Z]{4}/, message: "must be 4 uppercase letters")
  end
end
