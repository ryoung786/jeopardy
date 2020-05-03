defmodule Jeopardy.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :clues, {:array, :id}
      add :board_id, references(:boards, on_delete: :nothing)

      timestamps()
    end

    create index(:categories, [:board_id])
  end
end
