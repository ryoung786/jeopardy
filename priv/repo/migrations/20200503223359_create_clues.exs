defmodule Jeopardy.Repo.Migrations.CreateClues do
  use Ecto.Migration

  def change do
    create table(:clues) do
      add :clue_text, :string
      add :answer_text, :string
      add :value, :integer
      add :type, :string
      add :status, :string
      add :category_id, references(:categories, on_delete: :nothing)

      timestamps()
    end

    create index(:clues, [:category_id])
  end
end
