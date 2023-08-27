defmodule Jeopardy.FSM.AwaitingPlayers do
  @moduledoc """
  :awaiting_players -> :selecting_trebek
  """

  @behaviour Jeopardy.FSM.Handler

  alias Jeopardy.Game

  @impl true
  def valid_actions() do
    ~w/add_player remove_player continue/a
  end

  @impl true
  def handle_action(:add_player, %Game{} = game, name), do: add_player(game, name)

  def add_player(%Game{} = game, name) do
    if name not in game.players,
      do: {:ok, %{game | players: [name | game.players]}},
      else: {:error, :name_not_unique}
  end

  def remove_player(%Game{} = game, name) do
    if name in game.players,
      do: {:ok, %{game | players: List.delete(game.players, name)}},
      else: {:error, :player_not_found}
  end

  def continue(%Game{} = game) do
    if Enum.count(game.players) >= 2,
      do: {:ok, %{game | status: :selecting_trebek}},
      else: {:error, :needs_at_least_2_players}
  end
end
