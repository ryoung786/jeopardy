defmodule Jeopardy.Repo.Migrations.AddFinalJeopardyScoreUpdatedToPlayer do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :final_jeopardy_score_updated, :boolean, default: false
    end
  end
end
