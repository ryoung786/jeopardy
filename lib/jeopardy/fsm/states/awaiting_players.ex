defmodule Jeopardy.FSM.AwaitingPlayers do
  @moduledoc """
  :awaiting_players -> :selecting_trebek
  """

  use Jeopardy.FSM.State

  alias Jeopardy.FSM
  alias Jeopardy.FSM.SelectingTrebek
  alias Jeopardy.Game

  @impl true
  def valid_actions() do
    ~w/add_player remove_player continue load_game/a
  end

  @impl true
  def handle_action(:add_player, %Game{} = game, name), do: add_player(game, name)
  def handle_action(:remove_player, %Game{} = game, name), do: remove_player(game, name)
  def handle_action(:continue, %Game{} = game, _), do: continue(game)

  def handle_action(:load_game, %Game{} = game, jarchive_game_id),
    do: load_game(game, jarchive_game_id)

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
      FSM.broadcast(game, {:status_changed, SelectingTrebek})
      {:ok, %{game | fsm: FSM.to_state(SelectingTrebek, game)}}
    else
      {:error, :needs_at_least_2_players}
    end
  end

  def load_game(%Game{} = game, jarchive_game_id) do
    with {:ok, jarchive_game} <- Jeopardy.JArchive.load_game(jarchive_game_id) do
      broadcast_data = Map.take(jarchive_game, ~w/air_date comments/a)
      FSM.broadcast(game, {:jarchive_game_loaded, broadcast_data})

      {:ok, %{game | jarchive_game: jarchive_game}}
    end
  end
end
