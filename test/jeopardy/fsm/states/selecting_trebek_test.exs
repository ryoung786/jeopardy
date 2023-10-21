defmodule Jeopardy.FSM.SelectingTrebekTest do
  use ExUnit.Case, async: true

  alias Jeopardy.FSM
  alias Jeopardy.FSM.IntroducingRoles
  alias Jeopardy.FSM.SelectingTrebek
  alias Jeopardy.Game
  alias Jeopardy.Player

  describe "SelectingTrebek.select_trebek/2" do
    test "advances to the next state" do
      players = %{"ryan" => %Player{name: "ryan"}, "john" => %Player{name: "john"}}
      game = FSM.to_state(%Game{players: players}, SelectingTrebek)
      {:ok, game} = SelectingTrebek.select_trebek(game, "ryan")
      assert %{state: IntroducingRoles} = game.fsm
      assert "ryan" = game.trebek
    end

    test "doesn't advance if player doesn't exist" do
      players = %{"ryan" => %Player{name: "ryan"}, "john" => %Player{name: "john"}}
      game = FSM.to_state(%Game{players: players}, SelectingTrebek)
      assert {:error, :player_does_not_exist} = SelectingTrebek.select_trebek(game, "bob")
    end
  end
end
