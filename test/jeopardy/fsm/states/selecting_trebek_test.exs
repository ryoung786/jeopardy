defmodule Jeopardy.FSM.SelectingTrebekTest do
  use ExUnit.Case, async: true

  alias Jeopardy.FSM
  alias Jeopardy.FSM.SelectingTrebek
  alias Jeopardy.FSM.IntroducingRoles
  alias Jeopardy.Game

  describe "SelectingTrebek.select_trebek/2" do
    test "advances to the next state" do
      game = %Game{fsm: FSM.to_state(SelectingTrebek), players: ["ryan", "john"]}
      {:ok, game} = SelectingTrebek.select_trebek(game, "ryan")
      assert %{state: IntroducingRoles} = game.fsm
      assert "ryan" = game.trebek
    end

    test "doesn't advance if player doesn't exist" do
      game = %Game{fsm: FSM.to_state(SelectingTrebek), players: ["ryan", "john"]}
      assert {:error, :player_does_not_exist} = SelectingTrebek.select_trebek(game, "bob")
    end
  end
end
