defmodule Jeopardy.FSM.IntroducingRoles do
  @moduledoc """
  :introducing_roles -> :revealing_board
  """

  use Jeopardy.FSM.Handler

  alias Jeopardy.Game
  alias Jeopardy.Board
  alias Jeopardy.FSM.RevealingBoard

  @impl true
  def valid_actions(), do: ~w/continue/a

  @impl true
  def handle_action(:continue, %Game{} = game, _args), do: continue(game)

  defp continue(game) do
    {:ok,
     game
     |> Map.put(:fsm_handler, RevealingBoard)
     |> Map.put(:state_data, RevealingBoard.initial_state())
     |> Map.put(:board, Board.from_game(game.jarchive_game, :jeopardy))}
  end
end
