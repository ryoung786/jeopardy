defmodule Jeopardy.Cron.CullOldRecords do
  use GenServer
  import Ecto.Query
  require Logger

  @moduledoc "Every <config frequency>, replicate our DB updates into Google Cloud Storage"

  def start_link(_), do: start_link()
  def start_link, do: GenServer.start_link(__MODULE__, %{})

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    cull()

    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    frequency = Application.fetch_env!(:jeopardy, __MODULE__)[:frequency]
    Process.send_after(self(), :work, frequency)
  end

  def cull(),
    do:
      ~w(games players clues)
      |> Enum.each(&cull/1)

  defp cull(table) do
    %{^table => module} = %{
      "games" => Jeopardy.Games.Game,
      "players" => Jeopardy.Games.Player,
      "clues" => Jeopardy.Games.Clue
    }

    from(x in module, where: x.updated_at < ago(14, "day"))
    |> Jeopardy.Repo.delete_all()
  end
end
