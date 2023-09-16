defmodule Jeopardy.FSM.IntroducingRoles do
  @moduledoc """
  :introducing_roles -> :revealing_board
  """

  @behaviour Jeopardy.FSM.Handler

  alias Jeopardy.Game
  alias Jeopardy.Board

  @impl true
  def valid_actions(), do: ~w/continue/a

  @impl true
  def handle_action(:continue, %Game{} = game, _args), do: continue(game)

  defp continue(game) do
    {:ok,
     game
     |> Map.put(:status, :revealing_board)
     |> Map.put(:state_data, Jeopardy.FSM.RevealingBoard.initial_state())
     |> Map.put(:board, Board.from_game(game.jarchive_game, :jeopardy))}
  end
end
