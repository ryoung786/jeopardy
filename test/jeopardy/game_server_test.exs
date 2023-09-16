defmodule Jeopardy.GameServerTest do
  use ExUnit.Case, async: true

  alias Jeopardy.GameServer
  alias Jeopardy.Game
  alias Jeopardy.FSM

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
  end
end
