defmodule Jeopardy.FSM.AwaitingPlayers do
  @moduledoc """
  :awaiting_players -> :selecting_trebek
  """

  use Jeopardy.FSM.State

  alias Jeopardy.FSM
  alias Jeopardy.FSM.Messages.JArchiveGameLoaded
  alias Jeopardy.FSM.Messages.PlayerAdded
  alias Jeopardy.FSM.Messages.PlayerRemoved
  alias Jeopardy.FSM.SelectingTrebek
  alias Jeopardy.Game

  @impl true
  def valid_actions do
    ~w/add_player remove_player continue load_game/a
  end

  @impl true
  def handle_action(:add_player, %Game{} = game, name), do: add_player(game, name)
  def handle_action(:remove_player, %Game{} = game, name), do: remove_player(game, name)
  def handle_action(:continue, %Game{} = game, _), do: continue(game)

  def handle_action(:load_game, %Game{} = game, jarchive_game_id), do: load_game(game, jarchive_game_id)

  def add_player(%Game{} = game, name) do
    if name in game.players do
      {:error, :name_not_unique}
    else
      FSM.broadcast(game, %PlayerAdded{name: name})
      {:ok, %{game | players: [name | game.players]}}
    end
  end

  def remove_player(%Game{} = game, name) do
    if name in game.players do
      FSM.broadcast(game, %PlayerRemoved{name: name})
      {:ok, %{game | players: List.delete(game.players, name)}}
    else
      {:error, :player_not_found}
    end
  end

  def continue(%Game{} = game) do
    if Enum.count(game.players) >= 2 do
      {:ok, FSM.to_state(game, SelectingTrebek)}
    else
      {:error, :needs_at_least_2_players}
    end
  end

  def load_game(%Game{} = game, jarchive_game_id) do
    with {:ok, jarchive_game} <- Jeopardy.JArchive.load_game(jarchive_game_id) do
      FSM.broadcast(game, %JArchiveGameLoaded{
        air_date: jarchive_game.air_date,
        comments: jarchive_game.comments
      })

      {:ok, %{game | jarchive_game: jarchive_game}}
    end
  end
end
