defmodule Jeopardy.FSM.IntroducingRolesTest do
  use ExUnit.Case, async: true

  alias Jeopardy.Game
  alias Jeopardy.GameServer

  describe "IntroducingRoles.continue/1" do
    test "sets up the board" do
      code = GameServer.new_game_server("basic")
      GameServer.action(code, :add_player, "ryan")
      GameServer.action(code, :add_player, "john")
      GameServer.action(code, :continue)
      GameServer.action(code, :select_trebek, "john")
      GameServer.action(code, :continue)
      {:ok, %Game{board: board}} = GameServer.get_game(code)

      assert board.categories == ["THE OLD TESTAMENT", "xyz"]

      assert board.clues["xyz"][500].answer == "bar"
    end
  end
end
