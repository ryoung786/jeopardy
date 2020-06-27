defmodule Jeopardy.Repo.Migrations.AddReplicatedAtColumn do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :replicated_at, :utc_datetime, default: fragment("to_timestamp(0)")
    end

    alter table(:players) do
      add :replicated_at, :utc_datetime, default: fragment("to_timestamp(0)")
    end

    alter table(:clues) do
      add :replicated_at, :utc_datetime, default: fragment("to_timestamp(0)")
    end
  end
end
