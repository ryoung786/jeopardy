defmodule Jeopardy.BIReplication do
  use GenServer
  require Logger

  @moduledoc "Every hour, replicates our DB into Google Cloud Storage"

  def start_link(_), do: start_link()
  def start_link, do: GenServer.start_link(__MODULE__, %{})

  def init(state) do
    # Schedule work to be performed at some point
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Do the work you desire here
    Mix.Tasks.Etl.run(:incremental_updates)

    # Reschedule once more
    schedule_work()
    {:noreply, state}
  end

  # In 1 hour
  defp schedule_work(), do: Process.send_after(self(), :work, 1 * 60 * 60 * 1000)
end
