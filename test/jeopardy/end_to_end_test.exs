defmodule Jeopardy.EndToEndTest do
  use ExUnit.Case

  alias Jeopardy.FSM
  alias Jeopardy.GameServer

  describe "Jeopardy" do
    @tag capture_log: true
    test "play a full game" do
      code = GameServer.new_game_server(game_id: "basic")
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
      GameServer.action(code, :buzz, {"a", 0})
      GameServer.action(code, :buzz_window_expired)

      assert fsm_state(code) == FSM.AwaitingAnswer
      {:ok, game} = GameServer.action(code, :answered, :incorrect)
      assert game.contestants["a"].score == -100
      assert fsm_state(code) == FSM.AwaitingBuzz
      {:error, :already_answered_incorrectly} = GameServer.action(code, :buzz, {"a", 2})
      GameServer.action(code, :time_expired)

      assert fsm_state(code) == FSM.ReadingAnswer
      GameServer.action(code, :finished_reading)

      assert fsm_state(code) == FSM.SelectingClue
      GameServer.action(code, :clue_selected, {"xyz", 500})

      assert fsm_state(code) == FSM.ReadingClue
      GameServer.action(code, :finished_reading)

      assert fsm_state(code) == FSM.AwaitingBuzz
      GameServer.action(code, :buzz, {"b", 0})
      GameServer.action(code, :buzz_window_expired)

      assert fsm_state(code) == FSM.AwaitingAnswer
      {:ok, game} = GameServer.action(code, :answered, :correct)
      assert game.contestants["b"].score == 500

      assert fsm_state(code) == FSM.RecappingRound
      GameServer.action(code, :next_round)

      assert fsm_state(code) == FSM.RevealingBoard
      GameServer.action(code, :reveal_next_category)

      assert fsm_state(code) == FSM.RevealingBoard
      GameServer.action(code, :reveal_next_category)

      assert fsm_state(code) == FSM.SelectingClue
      GameServer.action(code, :clue_selected, {"WORLD HISTORY", 200})

      assert fsm_state(code) == FSM.ReadingClue
      GameServer.action(code, :finished_reading)

      assert fsm_state(code) == FSM.AwaitingBuzz
      GameServer.action(code, :buzz, {"a", 0})
      GameServer.action(code, :buzz_window_expired)

      assert fsm_state(code) == FSM.AwaitingAnswer
      GameServer.action(code, :answered, :incorrect)

      assert fsm_state(code) == FSM.AwaitingBuzz
      GameServer.action(code, :buzz, {"b", 0})
      GameServer.action(code, :buzz_window_expired)

      assert fsm_state(code) == FSM.AwaitingAnswer
      {:ok, game} = GameServer.action(code, :answered, :incorrect)

      assert fsm_state(code) == FSM.ReadingAnswer
      GameServer.action(code, :finished_reading)

      assert fsm_state(code) == FSM.RecappingRound
      assert %{"a" => %{score: -300}, "b" => %{score: 300}} = game.contestants
      {:ok, game} = GameServer.action(code, :zero_out_negative_scores)
      assert %{"a" => %{score: 0}, "b" => %{score: 300}} = game.contestants
      GameServer.action(code, :next_round)

      assert fsm_state(code) == FSM.AwaitingFinalJeopardyWagers
      assert {:error, _} = GameServer.action(code, :wagered, {"b", 301})
      GameServer.action(code, :wagered, {"b", 100})

      assert fsm_state(code) == FSM.ReadingFinalJeopardyClue
      GameServer.action(code, :answered, {"b", "some answer"})

      assert fsm_state(code) == FSM.ReadingFinalJeopardyClue
      GameServer.action(code, :time_expired)

      assert fsm_state(code) == FSM.GradingFinalJeopardyAnswers
      GameServer.action(code, :submitted_grades, ["b"])

      assert fsm_state(code) == FSM.RevealingFinalJeopardyAnswers
      GameServer.action(code, :revealed, :name)
      GameServer.action(code, :revealed, :wager)
      GameServer.action(code, :revealed, :answer)
      GameServer.action(code, :revealed, :next_contestant)
      GameServer.action(code, :revealed, :name)
      GameServer.action(code, :revealed, :wager)
      GameServer.action(code, :revealed, :answer)
      {:ok, game} = GameServer.action(code, :revealed, :game_over)
      assert game.contestants["b"].score == 400

      assert fsm_state(code) == FSM.GameOver
      {:ok, game} = GameServer.action(code, :play_again)
      assert fsm_state(code) == FSM.AwaitingPlayers
      assert ["a", "b", "trebek"] = game.players |> Map.keys() |> Enum.sort()
    end

    @tag capture_log: true
    test "daily double" do
      code = GameServer.new_game_server(game_id: "daily_double")
      GameServer.action(code, :add_player, "a")
      GameServer.action(code, :add_player, "trebek")
      GameServer.action(code, :continue)
      GameServer.action(code, :select_trebek, "trebek")
      GameServer.action(code, :continue)
      GameServer.action(code, :reveal_next_category)
      GameServer.action(code, :reveal_next_category)
      GameServer.action(code, :clue_selected, {"A", 100})

      assert fsm_state(code) == FSM.AwaitingDailyDoubleWager
      assert {:error, :wager_not_in_range} = GameServer.action(code, :wagered, 1_001)
      assert {:error, :wager_not_in_range} = GameServer.action(code, :wagered, 4)
      GameServer.action(code, :wagered, 1_000)

      assert fsm_state(code) == FSM.ReadingDailyDoubleClue
      {:ok, game} = GameServer.action(code, :answered, :correct)
      assert game.contestants["a"].score == 1_000

      {:ok, _} = GameServer.action(code, :next_round)
      GameServer.action(code, :reveal_next_category)
      GameServer.action(code, :reveal_next_category)
      GameServer.action(code, :clue_selected, {"B", 200})
      assert {:error, :wager_not_in_range} = GameServer.action(code, :wagered, 2_001)
      assert {:error, :wager_not_in_range} = GameServer.action(code, :wagered, 4)
      GameServer.action(code, :wagered, 1_001)
      {:ok, game} = GameServer.action(code, :answered, :incorrect)
      assert game.contestants["a"].score == -1
    end
  end

  defp fsm_state(code) do
    {:ok, %{fsm: %{state: state}}} = GameServer.get_game(code)
    state
  end
end
