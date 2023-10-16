defmodule Jeopardy.FSM.ReadingAnswer do
  @moduledoc """
  reading answer -> selecting clue | recapping round
  """

  use Jeopardy.FSM.State

  alias Jeopardy.Board

  @impl true
  def valid_actions, do: ~w/finished_reading/a

  @impl true
  def handle_action(:finished_reading, game, _), do: continue(game)

  defp continue(game) do
    next = if Board.empty?(game.board), do: FSM.RecappingRound, else: FSM.SelectingClue
    {:ok, FSM.to_state(game, next)}
  end
end
