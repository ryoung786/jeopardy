defmodule Jeopardy.Drafts.Clue do
  use Ecto.Schema
  import Ecto.Changeset

  defstruct category: "", clue: "", answer: "", type: "", value: 0

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
