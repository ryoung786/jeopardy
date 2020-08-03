defmodule Jeopardy.Drafts.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "draft_games" do
    field :owner_id, :id
    field :owner_type, :string
    field :name, :string
    field :description, :string
    field :tags, {:array, :string}, default: []
    field :format, :string, default: "jeopardy"
    field :clues, :map, default: %{}

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:owner_id, :owner_type, :name, :description, :tags, :format, :clues])
    |> validate_required([:owner_id, :owner_type, :name, :description, :tags, :format, :clues])
    |> validate_inclusion(:owner_type, ~w(user))
    |> validate_inclusion(:format, ~w(jeopardy))
  end

  def owner(%Jeopardy.Drafts.Game{owner_type: owner_type} = game) do
    %{^owner_type => module} = %{"user" => Jeopardy.Users.User}
    Jeopardy.Repo.get(module, game.owner_id)
  end
end
