defmodule Jeopardy.GameServerTest do
  use ExUnit.Case, async: true

  alias Jeopardy.GameServer
  alias Jeopardy.Game
  alias Jeopardy.FSM

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
      assert ["ryan"] = game.players
    end

    test "action/3 shows invalid action", %{code: code} do
      {:ok, game} = GameServer.get_game(code)
      assert %FSM{state: FSM.AwaitingPlayers} = game.fsm

      assert {:error, :invalid_action} = GameServer.action(code, :foo, "ryan")
    end

    test "terminates after inactivity" do
      code = GameServer.new_game_server(timeout: 2)

      # each GenServer msg resets the timeout
      assert {:ok, _} = GameServer.get_game(code)
      Process.sleep(1)
      assert {:ok, _} = GameServer.get_game(code) |> dbg()

      Process.sleep(2)
      assert {:error, :game_not_found} = GameServer.get_game(code)
    end
  end
end
