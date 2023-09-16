defmodule Jeopardy.FSM.AwaitingPlayersTest do
  use ExUnit.Case, async: true

  alias Jeopardy.FSM
  alias Jeopardy.FSM.AwaitingPlayers
  alias Jeopardy.FSM.SelectingTrebek
  alias Jeopardy.Game

  describe "AwaitingPlayers.add_player/2" do
    test "adds a player" do
      {:ok, game} = AwaitingPlayers.add_player(%Game{}, "ryan")
      {:ok, game} = AwaitingPlayers.add_player(game, "john")

      assert ["john", "ryan"] = game.players
    end

    test "enforces unique names" do
      {:ok, game} = AwaitingPlayers.add_player(%Game{}, "ryan")
      assert {:error, :name_not_unique} = AwaitingPlayers.add_player(game, "ryan")
    end
  end

  describe "AwaitingPlayers.remove_player/2" do
    test "removes a player" do
      {:ok, game} = AwaitingPlayers.add_player(%Game{}, "ryan")
      {:ok, game} = AwaitingPlayers.remove_player(game, "ryan")

      assert [] = game.players
    end

    test "returns error tuple when removing a nonexistant player" do
      assert {:error, :player_not_found} = AwaitingPlayers.remove_player(%Game{}, "ryan")
    end
  end

  describe "AwaitingPlayers.continue/1" do
    test "requires at least 2 players" do
      assert {:error, :needs_at_least_2_players} = AwaitingPlayers.continue(%Game{})
    end

    test "continues to next state" do
      {:ok, game} = AwaitingPlayers.add_player(%Game{}, "ryan")
      {:ok, game} = AwaitingPlayers.add_player(game, "john")

      {:ok, game} = AwaitingPlayers.continue(game)
      assert %FSM{state: SelectingTrebek} = game.fsm
    end
  end
end
