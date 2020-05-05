defmodule Jeopardy.JArchive.Game do
  use Jeopardy.JArchive.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, []}
  @derive {Phoenix.Param, key: :id}

  schema "games" do
    field :air_date, :date
    field :jeopardy_round_categories, {:array, :string}
    field :double_jeopardy_round_categories, {:array, :string}
    field :final_jeopardy_category, :string
    has_many :clues, Jeopardy.JArchive.Clue

    timestamps()
  end

  @doc false
  def changeset(archive, attrs) do
    archive
    |> cast(attrs, [:board_id])
    |> validate_required([:board_id, :airdate])
  end
end
