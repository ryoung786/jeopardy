defmodule Jeopardy.FSM.AwaitingPlayers do
  @moduledoc """
  :awaiting_players -> :selecting_trebek
  """

  @behaviour Jeopardy.FSM.Handler

  alias Jeopardy.FSM
  alias Jeopardy.Game

  @impl true
  def valid_actions() do
    ~w/add_player remove_player continue/a
  end

  @impl true
  def handle_action(:add_player, %Game{} = game, name), do: add_player(game, name)
  def handle_action(:remove_player, %Game{} = game, name), do: remove_player(game, name)
  def handle_action(:continue, %Game{} = game, _), do: continue(game)

  def add_player(%Game{} = game, name) do
    if name not in game.players do
      FSM.broadcast(game, {:player_added, name})
      {:ok, %{game | players: [name | game.players]}}
    else
      {:error, :name_not_unique}
    end
  end

  def remove_player(%Game{} = game, name) do
    if name in game.players do
      FSM.broadcast(game, {:player_removed, name})
      {:ok, %{game | players: List.delete(game.players, name)}}
    else
      {:error, :player_not_found}
    end
  end

  def continue(%Game{} = game) do
    if Enum.count(game.players) >= 2 do
      FSM.broadcast(game, {:status_changed, :selecting_trebek})
      {:ok, %{game | status: :selecting_trebek}}
    else
      {:error, :needs_at_least_2_players}
    end
  end
end
