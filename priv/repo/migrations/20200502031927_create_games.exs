defmodule Jeopardy.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :code, :string, size: 4
      add :status, :string, default: "awaiting_start"
      add :round_status, :string, default: "awaiting_start"
      add :trebek, :string, size: 25
      add :buzzer, :string

      timestamps()
    end

  end
end
