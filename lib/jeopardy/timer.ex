defmodule Jeopardy.Timer do
  use GenServer
  require Logger

  def start(code, time), do: GenServer.start_link(__MODULE__, {code, time})

  def stop(code), do: Phoenix.PubSub.broadcast(Jeopardy.PubSub, "timer:#{code}", :stop)

  def init({code, time}) do
    Phoenix.PubSub.subscribe(Jeopardy.PubSub, "timer:#{code}")

    state = %{timer_ref: nil, timer: time, orig_time: time, code: code}

    Phoenix.PubSub.broadcast(Jeopardy.PubSub, "timer:#{code}", %{
      event: :timer_start,
      time_left: time
    })

    {:ok, state}
  end

  def handle_info(:update, %{timer: t, code: code}) when t <= 0 do
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, "timer:#{code}", %{event: :timer_expired})
    {:stop, :normal, nil}
  end

  def handle_info(:update, %{timer: time, orig_time: orig, code: code}) do
    leftover = time - 1
    timer_ref = schedule_timer(1_000)

    Phoenix.PubSub.broadcast(Jeopardy.PubSub, "timer:#{code}", %{
      event: :timer_tick,
      time_left: time
    })

    {:noreply, %{timer_ref: timer_ref, timer: leftover, orig_time: orig, code: code}}
  end

  def handle_info(%{event: :timer_start}, state) do
    timer_ref = schedule_timer(1_000)
    {:noreply, %{state | timer: state.timer - 1, timer_ref: timer_ref}}
  end

  def handle_info(:reset, %{timer_ref: old_timer_ref, orig_time: orig, code: code}) do
    cancel_timer(old_timer_ref)
    {:noreply, %{timer_ref: nil, timer: orig, orig_time: orig, code: code}}
  end

  def handle_info(:pause, %{timer_ref: old_timer_ref, timer: timer, orig_time: orig, code: code}) do
    cancel_timer(old_timer_ref)
    {:noreply, %{timer_ref: nil, timer: timer, orig_time: orig, code: code}}
  end

  def handle_info(:stop, _state), do: {:stop, :normal, nil}
  def handle_info(_, state), do: {:noreply, state}

  defp schedule_timer(interval), do: Process.send_after(self(), :update, interval)

  defp cancel_timer(nil), do: :ok
  defp cancel_timer(ref), do: Process.cancel_timer(ref)
end
