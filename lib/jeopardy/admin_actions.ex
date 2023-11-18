defmodule Jeopardy.AdminActions do
  @moduledoc """
    Actions that an admin or Trebek can execute at any time, regardless of the game's current state.
  """

  alias Jeopardy.FSM
  alias Jeopardy.Game

  def handle_action(:set_score, game, {name, score}) do
    with game <- Game.set_contestant_score(game, name, score, true) do
      {:ok, game}
    end
  end

  def handle_action(:skip_to_next_round, game, _) do
    case game.round do
      :final_jeopardy -> {:ok, game}
      _ -> {:ok, FSM.to_state(game, FSM.RecappingRound)}
    end
  end
end
