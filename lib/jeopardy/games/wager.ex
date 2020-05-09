defmodule Jeopardy.Games.Wager do
  use Jeopardy.Games.Schema
  import Ecto.Changeset

  embedded_schema do
    field :amount, :integer
  end

  @doc false
  def changeset(%Jeopardy.Games.Wager{} = wager, attrs, min, max) do
    wager
    |> cast(attrs, [:amount])
    |> validate_required([:amount])
    |> validate_number(:amount, greater_than_or_equal_to: min, less_than_or_equal_to: max)
  end

  def validate(params, min, max) do
    changeset = Jeopardy.Games.Wager.changeset(%Jeopardy.Games.Wager{}, params, min, max)
    apply_action(changeset, :update)
  end
end
