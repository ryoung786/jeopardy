defmodule Jeopardy.JArchive.Cron do
  @moduledoc false
  use GenServer

  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    :timer.send_interval(:timer.hours(24), :work)
    {:ok, state}
  end

  def handle_info(:work, state) do
    Logger.info("Checking for new episodes")
    Jeopardy.JArchive.Downloader.download_all_seasons()
    {:noreply, state}
  end
end
