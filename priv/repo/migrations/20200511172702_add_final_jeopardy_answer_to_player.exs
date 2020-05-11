defmodule Jeopardy.Repo.Migrations.AddFinalJeopardyAnswerToPlayer do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :final_jeopardy_answer, :string, default: "", size: 512
    end
  end
end
