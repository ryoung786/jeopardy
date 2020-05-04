defmodule Jeopardy.JArchive.Game do
  use Jeopardy.JArchive.Schema
  import Ecto.Changeset

  @schema_prefix "jarchive"

  schema "games" do
    has_one :board, Jeopardy.JArchive.Board

    timestamps()
  end

  @doc false
  def changeset(archive, attrs) do
    archive
    |> cast(attrs, [:board_id])
    |> validate_required([:board_id])
  end
end
