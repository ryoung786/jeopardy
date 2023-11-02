defmodule Jeopardy.FSM.ReadingClue do
  @moduledoc """
  reading clue -> awaiting buzz
  """

  use Jeopardy.FSM.State

  @impl true
  def valid_actions, do: ~w/finished_reading/a

  @impl true
  def handle_action(:finished_reading, game, _), do: unlock_buzzers(game)

  defp unlock_buzzers(game) do
    {:ok,
     game
     |> Map.put(:buzzer, nil)
     |> FSM.to_state(FSM.AwaitingBuzz)}
  end
end
