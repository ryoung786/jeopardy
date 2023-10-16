defmodule Jeopardy.FSM.AwaitingBuzz do
  @moduledoc """
  awaiting buzz -> awaiting answer | reading answer
  """

  use Jeopardy.FSM.State

  alias Jeopardy.GameServer
  alias Jeopardy.Timers

  @timer_seconds 4

  @impl true
  def valid_actions, do: ~w/buzz time_expired/a

  @impl true
  def initial_data(game) do
    {:ok, tref} =
      :timer.apply_after(:timer.seconds(@timer_seconds), GameServer, :action, [
        game.code,
        :time_expired,
        nil
      ])

    %{expires_at: Timers.add(@timer_seconds), tref: tref}
  end

  @impl true
  def handle_action(:buzz, game, contestant_name), do: buzz(game, contestant_name)
  def handle_action(:time_expired, game, _), do: time_expired(game)

  defp buzz(game, contestant_name) do
    with :ok <- validate_contestant(game, contestant_name) do
      :timer.cancel(game.fsm.data.tref)

      {:ok,
       game
       |> Map.put(:buzzer, contestant_name)
       |> FSM.to_state(FSM.AwaitingAnswer)}
    end
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
