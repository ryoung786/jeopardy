defmodule Jeopardy.Games.Login do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :name, :string, null: false, size: 25
    field :code, :string, null: false, size: 4
  end

  @doc false
  def changeset(%Jeopardy.Games.Login{} = login \\ %Jeopardy.Games.Login{}, attrs \\ %{}) do
    login
    |> cast(attrs, [:name, :code])
    |> update_change(:name, &String.trim/1)
    |> update_change(:code, &String.trim/1)
    |> update_change(:code, &String.upcase/1)
    |> validate_required([:name, :code])
    |> validate_length(:name, max: 25, message: "Keep it short! 25 letters is the max.")
    |> validate_length(:code, is: 4, message: "Codes are 4 letters long")
    # |> validate_format(:code, ~r/^[A-Z]{4}$/, message: "must be 4 uppercase letters")
  end

  def validate(params) do
    changeset = Jeopardy.Games.Login.changeset(%Jeopardy.Games.Login{}, params)
    apply_action(changeset, :update)
  end
end
