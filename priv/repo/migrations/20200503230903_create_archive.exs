defmodule Jeopardy.Repo.Migrations.CreateJArchive do
  use Ecto.Migration

  def change do
    create table(:games, prefix: "jarchive", primary_key: false) do
      add :id, :id, primary_key: true
      add :jeopardy_round_categories, {:array, :string}
      add :double_jeopardy_round_categories, {:array, :string}
      add :final_jeopardy_category, :string
      add :air_date, :date

      timestamps()
    end

    create table(:clues, prefix: "jarchive") do
      add :clue_text, :string, size: 512
      add :answer_text, :string
      add :value, :integer
      add :round, :string # jeopardy, double_jeopardy, final_jeopardy
      add :type, :string # standard, daily_double
      add :category, :string
      add :game_id, references(:games, on_delete: :nothing)

      timestamps()
    end

    create index(:clues, [:game_id], prefix: "jarchive")
  end
end
