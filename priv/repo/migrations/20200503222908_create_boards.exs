defmodule Jeopardy.Repo.Migrations.CreateBoards do
  use Ecto.Migration

  def change do
    create table(:boards) do
      add :categories, {:array, :integer}
      add :game_id, references(:games, on_delete: :nothing)

      timestamps()
    end

    create index(:boards, [:game_id])
  end
end
