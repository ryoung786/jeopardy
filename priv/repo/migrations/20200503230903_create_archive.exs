defmodule Jeopardy.Repo.Migrations.CreateJArchive do
  use Ecto.Migration

  def change do
    create table(:games, prefix: "jarchive") do
      timestamps()
    end


    create table(:boards, prefix: "jarchive") do
      add :category_array, {:array, :id}
      add :game_id, references(:games, on_delete: :nothing)

      timestamps()
    end

    create index(:boards, [:game_id], prefix: "jarchive")


    create table(:categories, prefix: "jarchive") do
      add :name, :string
      add :clue_array, {:array, :id}
      add :board_id, references(:boards, on_delete: :nothing)

      timestamps()
    end

    create index(:categories, [:board_id], prefix: "jarchive")


    create table(:clues, prefix: "jarchive") do
      add :clue_text, :string
      add :answer_text, :string
      add :value, :integer
      add :type, :string
      add :category_id, references(:categories, on_delete: :nothing)

      timestamps()
    end

    create index(:clues, [:category_id], prefix: "jarchive")
  end
end
