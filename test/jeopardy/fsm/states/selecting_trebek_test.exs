defmodule Jeopardy.FSM.SelectingTrebekTest do
  use ExUnit.Case, async: true

  alias Jeopardy.FSM
  alias Jeopardy.FSM.IntroducingRoles
  alias Jeopardy.FSM.SelectingTrebek
  alias Jeopardy.Game

  describe "SelectingTrebek.select_trebek/2" do
    test "advances to the next state" do
      game = FSM.to_state(%Game{players: ["ryan", "john"]}, SelectingTrebek)
      {:ok, game} = SelectingTrebek.select_trebek(game, "ryan")
      assert %{state: IntroducingRoles} = game.fsm
      assert "ryan" = game.trebek
    end

    test "doesn't advance if player doesn't exist" do
      game = FSM.to_state(%Game{players: ["ryan", "john"]}, SelectingTrebek)
      assert {:error, :player_does_not_exist} = SelectingTrebek.select_trebek(game, "bob")
    end
  end
end
