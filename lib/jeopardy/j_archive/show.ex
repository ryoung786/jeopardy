defmodule Jeopardy.JArchive.Show do
  use Jeopardy.JArchive.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, []}
  @derive {Phoenix.Param, key: :id}

  schema "shows" do
    field :air_date, :date
    has_one :board, Jeopardy.JArchive.Board

    timestamps()
  end

  @doc false
  def changeset(archive, attrs) do
    archive
    |> cast(attrs, [:board_id])
    |> validate_required([:board_id, :airdate])
  end
end
