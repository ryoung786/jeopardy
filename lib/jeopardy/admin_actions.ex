defmodule Jeopardy.AdminActions do
  @moduledoc """
    Actions that an admin or Trebek can execute at any time, regardless of the game's current state.
  """

  alias Jeopardy.FSM
  alias Jeopardy.FSM.Messages.PlayerRemoved
  alias Jeopardy.Game

  def handle_action(:set_score, game, {name, score}) do
    game = Game.set_contestant_score(game, name, score)
    {:ok, game}
  end

  def handle_action(:skip_to_next_round, game, _) do
    case game.round do
      :final_jeopardy -> {:ok, game}
      _ -> {:ok, FSM.to_state(game, FSM.RecappingRound)}
    end
  end

  def handle_action(:remove_contestant, game, name) do
    if name in Map.keys(game.players) do
      FSM.broadcast(game, %PlayerRemoved{name: name})
      {:ok, %{game | contestants: Map.delete(game.contestants, name)}}
    else
      {:error, :player_not_found}
    end
  end
end
