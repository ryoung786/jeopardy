defmodule Jeopardy.EndToEndTest do
  use ExUnit.Case, asyc: true

  alias Jeopardy.GameServer
  alias Jeopardy.FSM

  describe "Jeopardy" do
    test "play a full game" do
      # awaiting_players
      code = GameServer.new_game_server("basic")
      GameServer.action(code, :add_player, "a")
      GameServer.action(code, :add_player, "b")
      GameServer.action(code, :add_player, "trebek")
      GameServer.action(code, :continue)

      assert fsm_state(code) == FSM.SelectingTrebek
      GameServer.action(code, :select_trebek, "trebek")

      assert fsm_state(code) == FSM.IntroducingRoles
      GameServer.action(code, :continue)

      assert fsm_state(code) == FSM.RevealingBoard
      GameServer.action(code, :reveal_next_category)

      assert fsm_state(code) == FSM.RevealingBoard
      GameServer.action(code, :reveal_next_category)

      assert fsm_state(code) == FSM.RevealingBoard
      GameServer.action(code, :reveal_next_category)

      assert fsm_state(code) == FSM.SelectingClue
      GameServer.action(code, :clue_selected, {"THE OLD TESTAMENT", 100})

      assert fsm_state(code) == FSM.ReadingClue
      GameServer.action(code, :finished_reading)

      assert fsm_state(code) == FSM.AwaitingBuzz
      GameServer.action(code, :buzz, "a")

      assert fsm_state(code) == FSM.AwaitingAnswer
      {:ok, game} = GameServer.action(code, :answered, :incorrect)
      assert game.contestants["a"].score == -100
      assert fsm_state(code) == FSM.AwaitingBuzz
      {:error, :already_answered_incorrectly} = GameServer.action(code, :buzz, "a")
      GameServer.action(code, :time_expired)

      assert fsm_state(code) == FSM.ReadingAnswer
      GameServer.action(code, :finished_reading)

      assert fsm_state(code) == FSM.SelectingClue
      GameServer.action(code, :clue_selected, {"xyz", 500})

      assert fsm_state(code) == FSM.ReadingClue
      GameServer.action(code, :finished_reading)

      assert fsm_state(code) == FSM.AwaitingBuzz
      GameServer.action(code, :buzz, "b")

      assert fsm_state(code) == FSM.AwaitingAnswer
      {:ok, game} = GameServer.action(code, :answered, :correct)
      assert game.contestants["b"].score == 500

      assert fsm_state(code) == FSM.RecappingRound
      GameServer.action(code, :next_round)

      assert fsm_state(code) == FSM.SelectingClue
      GameServer.action(code, :clue_selected, {"WORLD HISTORY", 200})

      assert fsm_state(code) == FSM.ReadingClue
      GameServer.action(code, :finished_reading)

      assert fsm_state(code) == FSM.AwaitingBuzz
      GameServer.action(code, :buzz, "a")

      assert fsm_state(code) == FSM.AwaitingAnswer
      GameServer.action(code, :answered, :incorrect)

      assert fsm_state(code) == FSM.AwaitingBuzz
      GameServer.action(code, :buzz, "b")

      assert fsm_state(code) == FSM.AwaitingAnswer
      {:ok, game} = GameServer.action(code, :answered, :incorrect)

      assert fsm_state(code) == FSM.RecappingRound
      assert %{"a" => %{score: -300}, "b" => %{score: 300}} = game.contestants
    end
  end

  defp fsm_state(code) do
    {:ok, %{fsm: %{state: state}}} = GameServer.get_game(code)
    state
  end
end
