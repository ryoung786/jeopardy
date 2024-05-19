defmodule Jeopardy.FSM.AwaitingBuzz do
  @moduledoc """
  awaiting buzz -> awaiting answer | reading answer

  There are a couple interesting timers that happen at this step:
  1. We start counting down immediately so that we can read the answer if nobody
     buzzes in.
  2. After the first player buzzes in, we continue accepting buzzes for a short
     window.  At the end of the window, the buzz with the earliest timestamp wins.

  ## More about the buzzer time window
  If two contestants buzz at the exact same time, but one has a faster connection
  or is significantly closer to the physical server, the difference in latency can
  mean that one player will consistently win the buzz.

  In order to combat this, a buzz will send the contestant name AND the unix timestamp
  of when they hit the buzzer (according to their browser Date.now function).  The
  GameServer receives the first buzz, but keeps accepting buzzes for a short period of
  time.  At the end of that time window, the earliest timestamp wins.

  There is still an advantage to the contestant with the lowest latency in that their
  client will receive the state change first and thus their buzzer will be available
  to be pressed sooner.  But at least this solves the problem of multiple people
  buzzing at the same time and the same players always losing out.

  ### A note on cheating vectors
  By accepting the client's unix timestamp, we open ourselves up to cheating.  A bad
  actor could set their timestamp to 0 and win every tie.  This is an acceptable
  risk given that
    1. only friends are using this game currently and it'd be insane for them to cheat
    2. you'd still have to buzz in within the short time window to have a chance
  """

  use Jeopardy.FSM.State

  alias Jeopardy.GameServer
  alias Jeopardy.Timers

  @timer_seconds 4
  @buzz_window_ms 200

  @impl true
  def valid_actions, do: ~w/buzz time_expired buzz_window_expired/a

  @impl true
  def initial_data(game) do
    {:ok, tref} =
      :timer.apply_after(:timer.seconds(@timer_seconds), GameServer, :action, [
        game.code,
        :time_expired,
        nil
      ])

    %{expires_at: Timers.add(@timer_seconds), tref: tref, fastest_buzz: nil}
  end

  @impl true
  def handle_action(:buzz, game, {contestant_name, timestamp}), do: buzz(game, contestant_name, timestamp)
  def handle_action(:time_expired, game, _), do: time_expired(game)
  def handle_action(:buzz_window_expired, game, _), do: buzz_window_expired(game)

  defp buzz(game, contestant_name, unix_timestamp) do
    with :ok <- validate_contestant(game, contestant_name) do
      :timer.cancel(game.fsm.data.tref)

      fastest_buzz =
        case game.fsm.data.fastest_buzz do
          nil ->
            # this is the first player to buzz in.  Wait 200ms to let others buzz in,
            # and the one who buzzed at the smallest client timestamp wins
            :timer.apply_after(@buzz_window_ms, GameServer, :action, [game.code, :buzz_window_expired, nil])
            {contestant_name, unix_timestamp}

          {name, ts} ->
            if unix_timestamp <= ts, do: {contestant_name, unix_timestamp}, else: {name, ts}
        end

      game = put_in(game.fsm.data.fastest_buzz, fastest_buzz)
      {:ok, game}
    end
  end

  defp buzz_window_expired(game) do
    {contestant_name, _timestamp} = game.fsm.data.fastest_buzz

    {:ok,
     game
     |> Map.put(:buzzer, contestant_name)
     |> FSM.to_state(FSM.AwaitingAnswer)}
  end

  defp time_expired(game) do
    {:ok, FSM.to_state(game, FSM.ReadingAnswer)}
  end

  defp validate_contestant(game, name) do
    cond do
      !Map.has_key?(game.contestants, name) -> {:error, :contestant_does_not_exist}
      name in game.clue.incorrect_contestants -> {:error, :already_answered_incorrectly}
      :else -> :ok
    end
  end
end
