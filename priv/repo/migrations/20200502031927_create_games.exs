defmodule Jeopardy.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :code, :string
      add :status, :string
      add :buzzer, :string

      timestamps()
    end

  end
end
