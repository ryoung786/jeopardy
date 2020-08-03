defmodule Jeopardy.Repo.Migrations.CreateDraftGames do
  use Ecto.Migration

  def change do
    create table(:draft_games) do
      add :owner_id, :id
      add :owner_type, :string
      add :name, :string
      add :description, :string
      add :tags, {:array, :string}, default: []
      add :format, :string
      add :clues, :map

      timestamps()
    end

    create index(:draft_games, [:owner_id, :owner_type])
  end
end
