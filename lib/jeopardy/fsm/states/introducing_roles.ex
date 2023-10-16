defmodule Jeopardy.FSM.IntroducingRoles do
  @moduledoc """
  :introducing_roles -> :revealing_board
  """

  use Jeopardy.FSM.State

  alias Jeopardy.Board
  alias Jeopardy.FSM
  alias Jeopardy.FSM.RevealingBoard
  alias Jeopardy.Game

  @impl true
  def valid_actions, do: ~w/continue/a

  @impl true
  def handle_action(:continue, %Game{} = game, _args), do: continue(game)

  defp continue(game) do
    board = Board.from_game(game.jarchive_game, :jeopardy)
    {:ok, FSM.to_state(%{game | board: board}, RevealingBoard)}
  end
end
