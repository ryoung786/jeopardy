defmodule Jeopardy.FSM.AwaitingBuzz do
  @moduledoc """
  awaiting buzz -> awaiting answer | reading answer
  """

  use Jeopardy.FSM.State

  @impl true
  def valid_actions(), do: ~w/buzz time_expired/a

  @impl true
  def handle_action(:buzz, game, contestant_name), do: buzz(game, contestant_name)
  def handle_action(:time_expired, game, _), do: time_expired(game)

  defp buzz(game, contestant_name) do
    with :ok <- validate_contestant(game, contestant_name) do
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
