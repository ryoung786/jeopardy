defmodule Jeopardy.JArchive.RecordedGame do
  @moduledoc false
  use TypedEctoSchema

  import Ecto.Changeset

  alias Jeopardy.JArchive.RecordedGame.Category

  @primary_key false
  typed_embedded_schema do
    field :air_date, :date
    field :comments, :string
    field :contestants, {:array, :string}
    field :season, :string

    embeds_one :categories, Categories, primary_key: false do
      field :jeopardy, {:array, :string}
      field :double_jeopardy, {:array, :string}
      field :final_jeopardy, :string
    end

    embeds_one :final_jeopardy, FinalJeopardy, primary_key: false do
      field :category, :string
      field :clue, :string
      field :answer, :string
    end

    embeds_many :jeopardy, Category
    embeds_many :double_jeopardy, Category
  end

  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, ~w/air_date comments contestants season/a)
    |> cast_embed(:categories, with: &categories_changeset/2)
    |> cast_embed(:final_jeopardy, with: &final_jeopardy_changeset/2)
    |> cast_embed(:jeopardy)
    |> cast_embed(:double_jeopardy)
  end

  defp categories_changeset(schema, data) do
    cast(schema, data, ~w/jeopardy double_jeopardy final_jeopardy/a)
  end

  defp final_jeopardy_changeset(schema, data) do
    cast(schema, data, ~w/category clue answer/a)
  end
end

defmodule Jeopardy.JArchive.RecordedGame.Category do
  @moduledoc false
  use TypedEctoSchema

  @primary_key false
  typed_embedded_schema do
    field :category, :string

    embeds_many :clues, Clue, primary_key: false do
      field :value, :integer
      field :category, :string
      field :answer, :string
      field :clue, :string
      field :daily_double?, :boolean, default: false
    end
  end

  def changeset(schema, data) do
    schema
    |> Ecto.Changeset.cast(data, ~w/category/a)
    |> Ecto.Changeset.cast_embed(:clues, with: &clue_changeset/2)
  end

  defp clue_changeset(schema, data) do
    Ecto.Changeset.cast(schema, data, ~w/value category answer clue daily_double?/a)
  end
end
