defmodule Jeopardy.GameServerTest do
  use ExUnit.Case

  alias Jeopardy.GameServer
  alias Jeopardy.Game

  describe "Jeopardy.GameServerTest" do
    setup do
      [code: GameServer.new_game_server()]
    end

    test "init", %{code: code} do
      assert %{
               code: ^code,
               game: %Game{},
               last_interaction: _datetime
             } = :sys.get_state(GameServer.game_pid(code))
    end

    test "add_player/2", %{code: code} do
      assert {:ok, ["ryan"]} = GameServer.add_player(code, "ryan")
      assert {:ok, ["john", "ryan"]} = GameServer.add_player(code, "john")
      assert {:error, :name_not_unique} = GameServer.add_player(code, "john")
    end

    test "remove_player/2", %{code: code} do
      assert {:ok, []} = GameServer.remove_player(code, "ryan")

      GameServer.add_player(code, "ryan")
      GameServer.add_player(code, "john")
      assert {:ok, ["john"]} = GameServer.remove_player(code, "ryan")
    end
  end
end
