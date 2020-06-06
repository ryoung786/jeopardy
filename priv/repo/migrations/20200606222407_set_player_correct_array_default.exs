defmodule Jeopardy.Repo.Migrations.SetPlayerCorrectArrayDefault do
  use Ecto.Migration

  def change do
    alter table(:players) do
      modify :correct_answers, {:array, :id}, default: []
      modify :incorrect_answers, {:array, :id}, default: []
    end
  end
end
