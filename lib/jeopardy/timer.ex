defmodule Jeopardy.Timer do
  use GenServer
  require Logger

  def start(code, time), do: GenServer.start_link(__MODULE__, {code, time}, name: :timer)
  def stop(), do: GenServer.stop(:timer)

  ##############################################################################
  ### Server

  # START
  def init({code, time}), do: {:ok, %{time_left: time, ref: schedule_timer(0), code: code}}

  # EXPIRATION
  def handle_info(:tick, %{time_left: t, code: code}) when t <= 0 do
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, "timer:#{code}", %{event: :timer_expired})
    Logger.warn("[xxx] #{t} seconds left!")
    {:stop, :normal, nil}
  end

  # TICK
  def handle_info(:tick, %{time_left: time, code: code}) do
    schedule_timer(1_000)

    Phoenix.PubSub.broadcast(Jeopardy.PubSub, "timer:#{code}", %{
      event: :timer_tick,
      time_left: time
    })

    Logger.warn("[xxx] #{time} seconds left!")
    {:noreply, %{time_left: time - 1, code: code}}
  end

  defp schedule_timer(interval), do: Process.send_after(self(), :tick, interval)
end
