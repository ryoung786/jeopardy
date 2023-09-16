defmodule Jeopardy.FSM.SelectingTrebekTest do
  use ExUnit.Case, async: true

  alias Jeopardy.FSM.SelectingTrebek
  alias Jeopardy.Game

  describe "SelectingTrebek.select_trebek/2" do
    test "advances to the next state" do
      game = %Game{fsm_handler: SelectingTrebek, players: ["ryan", "john"]}
      {:ok, game} = SelectingTrebek.select_trebek(game, "ryan")
      assert Jeopardy.FSM.IntroducingRoles == game.fsm_handler
      assert "ryan" = game.trebek
    end

    test "doesn't advance if player doesn't exist" do
      game = %Game{fsm_handler: SelectingTrebek, players: ["ryan", "john"]}
      assert {:error, :player_does_not_exist} = SelectingTrebek.select_trebek(game, "bob")
    end
  end
end
