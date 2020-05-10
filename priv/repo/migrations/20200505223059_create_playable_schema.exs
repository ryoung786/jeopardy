defmodule Jeopardy.Repo.Migrations.CreatePlayableSchema do
  use Ecto.Migration

  def down do
    drop table(:players)
    drop table(:clues)
    drop table(:games)
    drop SCHEMA jarchive CASCADE;
  end

  def up do
    execute "CREATE SCHEMA example"

    create table(:games) do
      add :code, :string, size: 4
      add :status, :string, default: "awaiting_start"
      add :round_status, :string, default: "awaiting_start"
      add :trebek, :string, size: 25
      add :is_active, :boolean

      add :board_control, :string, size: 25
      add :current_clue_id, :id
      add :buzzer_player, :string
      add :buzzer_lock_status, :string, default: "locked"

      add :jarchive_game_id, references(:games, prefix: "jarchive")
      add :jeopardy_round_categories, {:array, :string}, default: []
      add :double_jeopardy_round_categories, {:array, :string}, default: []
      add :final_jeopardy_category, :string
      add :air_date, :date

      timestamps()
    end

    create index(:games, [:code])
    create index(:games, [:code, :is_active])

    create table(:clues) do
      add :category, :string
      add :clue_text, :string, size: 1024
      add :answer_text, :string, size: 512
      add :value, :integer
      add :round, :string # jeopardy, double_jeopardy, final_jeopardy
      add :type, :string # standard, daily_double
      add :asked_status, :string # unasked, asked
      add :wager, :integer
      add :incorrect_players, {:array, :id}
      add :correct_players, {:array, :id}
      add :game_id, references(:games, on_delete: :nothing)

      timestamps()
    end

    create index(:clues, [:game_id])

    create table(:players) do
      add :name, :string
      add :score, :integer, default: 0
      add :final_jeopardy_wager, :integer
      add :correct_answers, {:array, :id}
      add :incorrect_answers, {:array, :id}
      add :game_id, references(:games, on_delete: :nothing)

      timestamps()
    end

    create index(:players, [:game_id])
  end
end
