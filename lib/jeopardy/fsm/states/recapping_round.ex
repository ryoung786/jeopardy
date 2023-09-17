defmodule Jeopardy.FSM.RecappingRound do
  @moduledoc """
  recapping round -> selecting clue | awaiting final jeopardy wagers
  """

  use Jeopardy.FSM.State
  alias Jeopardy.Game
  alias Jeopardy.Board

  @impl true
  def valid_actions(), do: ~w/next_round/a

  @impl true
  def handle_action(:next_round, game, _), do: go_to_next_round(game)

  defp go_to_next_round(%Game{round: :jeopardy} = game) do
    {:ok,
     game
     |> Map.put(:round, :double_jeopardy)
     |> Map.put(:board, Board.from_game(game.jarchive_game, :double_jeopardy))
     |> FSM.to_state(FSM.SelectingClue)}
  end

  defp go_to_next_round(%Game{round: :double_jeopardy} = game) do
    {:ok, %{game | round: :final_jeopardy} |> FSM.to_state(FSM.AwaitingFinalJeopardyWagers)}
  end
end
