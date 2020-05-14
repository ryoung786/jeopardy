defmodule Jeopardy.Timer do
  use GenServer
  require Logger

  # def start_link() do
  #   GenServer.start_link __MODULE__, %{}
  # end
  ## SERVER ##

  def init({game_id, time}) do
    Logger.warn "timer server started with id #{game_id}"
    IO.puts "timer server started with id #{game_id}"
    # EnchufeWeb.Endpoint.subscribe "timer:start", []

    Phoenix.PubSub.subscribe(Jeopardy.PubSub, "timer:#{game_id}")

    state = %{timer_ref: nil, timer: time, orig_time: time, id: game_id}
    {:ok, state}
  end

  def handle_info(:update, %{timer: 0, orig_time: orig, id: id}) do
    # broadcast 0, "TIMEEEE"
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, "timer:#{id}", :time_expired)
    IO.puts "time expired"
    {:noreply, %{timer_ref: nil, timer: 0, orig_time: orig, id: id}}
  end

  def handle_info(:update, %{timer: time, orig_time: orig, id: id}) do
    IO.puts "tick. time left #{time}"
    leftover = time - 1
    timer_ref = schedule_timer 1_000
    # broadcast leftover, "tick tock... tick tock"
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, "timer:#{id}", {:tick, leftover})
    {:noreply, %{timer_ref: timer_ref, timer: leftover, orig_time: orig, id: id}}
  end

  def handle_info(:start, state) do
    _timer_ref = schedule_timer 1_000
    # broadcast state.time, "Started timer!"
    IO.puts "started timer, state: #{inspect state}"
    IO.puts "started timer, time left #{state.timer}"
    {:noreply, %{state | timer: state.timer - 1}}
    # {:noreply, state}
  end
  def handle_info(:reset, %{timer_ref: old_timer_ref, orig_time: orig, id: id}) do
    cancel_timer(old_timer_ref)
    {:noreply, %{timer_ref: nil, timer: orig, orig_time: orig, id: id}}
  end
  def handle_info(:pause, %{timer_ref: old_timer_ref, timer: timer, orig_time: orig, id: id}) do
    cancel_timer(old_timer_ref)
    {:noreply, %{timer_ref: nil, timer: timer, orig_time: orig, id: id}}
  end

  def handle_info(_, state), do: {:noreply, state}

  defp schedule_timer(interval), do: Process.send_after self(), :update, interval

  defp cancel_timer(nil), do: :ok
  defp cancel_timer(ref), do: Process.cancel_timer(ref)

  # defp broadcast(time, response) do
    # Phoenix.PubSub.broadcast(Jeopardy.PubSub, "timer:#{game_id}", {:tick, time})
  # end
end
