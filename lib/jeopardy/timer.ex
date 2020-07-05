defmodule Jeopardy.Timer do
  use GenServer
  require Logger

  # TODO using String.to_atom instead of a Registry may be a memory leak

  def start(code, time),
    do: GenServer.start_link(__MODULE__, {code, time}, name: String.to_atom(code))

  def stop(code), do: GenServer.stop(String.to_atom(code))

  ##############################################################################
  ### Server

  # START
  def init({code, time}),
    do: {:ok, %{time_left: time, ref: schedule_timer(0), code: code}}

  # EXPIRATION
  def handle_info(:tick, %{time_left: t, code: code}) when t <= 0 do
    {topic, data} = {"timer:#{code}", %{event: :timer_expired}}
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, topic, data)
    {:stop, :normal, nil}
  end

  # TICK
  def handle_info(:tick, %{time_left: time, code: code}) do
    schedule_timer(1_000)

    Phoenix.PubSub.broadcast(Jeopardy.PubSub, "timer:#{code}", %{
      event: :timer_tick,
      time_left: time
    })

    {:noreply, %{time_left: time - 1, code: code}}
  end

  defp schedule_timer(interval), do: Process.send_after(self(), :tick, interval)
end
