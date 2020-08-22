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

  def clue_changeset(clue, attrs) do
    types = %{id: :integer, clue: :string, answer: :string, type: :string, value: :integer}
    max_msg = "Keep it short! 500 letters is the max."

    {clue, types}
    |> cast(attrs, Map.keys(types))
    # |> validate_required(~w(id clue answer type value)a)
    |> validate_number(:id, greater_than: 0)
    |> validate_length(:clue, max: 500, message: max_msg)
    |> validate_length(:answer, max: 500, message: max_msg)
    |> validate_inclusion(:type, ["standard", "daily_double"])
    |> validate_number(:value, greater_than: 0)
  end

  def final_jeopardy_changeset(fj_clue, attrs) do
    types = %{clue: :string, answer: :string, category: :string}
    max_msg = "Keep it short! 500 letters is the max."

    {fj_clue, types}
    |> cast(attrs, Map.keys(types))
    # |> validate_required(~w(clue answer category)a)
    |> validate_length(:clue, max: 500, message: max_msg)
    |> validate_length(:answer, max: 500, message: max_msg)
    |> validate_length(:category, max: 100, message: "Keep it short! 100 letters is the max.")
  end

  def category_changeset(category, attrs) do
    types = %{category: :string}
    max_msg = "Keep it short! 500 characters is the max."

    {category, types}
    |> cast(attrs, Map.keys(types))
    |> validate_required(~w(category)a)
    |> validate_length(:category, max: 500, message: max_msg)
  end
end
