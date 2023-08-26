defmodule Jeopardy.GameTest do
  use ExUnit.Case

  alias Jeopardy.Game

  describe "Jeopardy.Game.add_player/2" do
    test "can add multiple players" do
      {:ok, game} = Game.add_player(%Game{}, "ryan")
      assert ["ryan"] = game.players

      {:ok, game} = Game.add_player(game, "john")
      assert ["john", "ryan"] = game.players
    end

    test "enforces unique player names" do
      {:ok, game} = Game.add_player(%Game{}, "ryan")
      assert {:error, :name_not_unique} = Game.add_player(game, "ryan")
    end

    test "can only add if game status is :awaiting_players" do
      game = %Game{status: :game_over}
      assert {:error, :invalid_status} = Game.add_player(game, "john")
    end
  end

  describe "Jeopardy.Game.remove_player/2" do
    test "removes a player" do
      {:ok, game} = Game.add_player(%Game{}, "ryan")
      {:ok, game} = Game.remove_player(game, "ryan")
      assert [] = game.players
    end

    test "returns error if player name does not exist" do
      assert {:error, :player_does_not_exist} = Game.remove_player(%Game{}, "john")
    end

    test "can only remove if game status is :awaiting_players" do
      game = %Game{status: :game_over}
      assert {:error, :invalid_status} = Game.remove_player(game, "john")
    end
  end
end
