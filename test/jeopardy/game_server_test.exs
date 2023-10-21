defmodule Jeopardy.GameServerTest do
  use ExUnit.Case, async: true

  alias Jeopardy.FSM
  alias Jeopardy.Game
  alias Jeopardy.GameServer

  describe "Jeopardy.GameServer" do
    setup do
      [code: GameServer.new_game_server()]
    end

    test "init", %{code: code} do
      assert %{
               code: ^code,
               game: %Game{}
             } = :sys.get_state(GameServer.game_pid(code))
    end

    test "action/3 adds players", %{code: code} do
      {:ok, game} = GameServer.get_game(code)
      assert %FSM{state: FSM.AwaitingPlayers} = game.fsm

      assert {:ok, game} = GameServer.action(code, :add_player, "ryan")
      assert ["ryan"] = Map.keys(game.players)
    end

    @tag capture_log: true
    test "action/3 shows invalid action", %{code: code} do
      {:ok, game} = GameServer.get_game(code)
      assert %FSM{state: FSM.AwaitingPlayers} = game.fsm

      assert {:error, :invalid_action} = GameServer.action(code, :foo, "ryan")
    end

    test "terminates after inactivity" do
      code = GameServer.new_game_server(timeout: 100)

      # each GenServer msg resets the timeout
      assert {:ok, _} = GameServer.get_game(code)
      Process.sleep(1)
      assert {:ok, _} = GameServer.get_game(code)

      Process.sleep(101)
      assert {:error, :game_not_found} = GameServer.get_game(code)
    end
  end
end
