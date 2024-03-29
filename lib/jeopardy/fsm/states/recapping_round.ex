defmodule Jeopardy.FSM.RecappingRound do
  @moduledoc """
  recapping round -> selecting clue | awaiting final jeopardy wagers
  """

  use Jeopardy.FSM.State

  alias Jeopardy.Board
  alias Jeopardy.Board.Clue
  alias Jeopardy.Game

  @impl true
  def valid_actions, do: ~w/zero_out_negative_scores next_round/a

  @impl true
  def handle_action(:zero_out_negative_scores, game, _), do: {:ok, zero_out_negative_scores(game)}
  def handle_action(:next_round, game, _), do: go_to_next_round(game)

  defp zero_out_negative_scores(game) do
    contestants =
      Map.new(game.contestants, fn
        {name, %{score: x} = c} when x <= 0 -> {name, %{c | score: 0, final_jeopardy_wager: 0}}
        contestant -> contestant
      end)

    %{game | contestants: contestants}
  end

  defp go_to_next_round(%Game{round: :jeopardy} = game) do
    {:ok,
     game
     |> Map.put(:round, :double_jeopardy)
     |> Map.put(:board, Board.from_game(game.jarchive_game, :double_jeopardy))
     |> FSM.to_state(FSM.RevealingBoard)}
  end

  defp go_to_next_round(%Game{round: :double_jeopardy} = game) do
    clue = %Clue{
      category: game.jarchive_game.final_jeopardy.category,
      clue: game.jarchive_game.final_jeopardy.clue,
      answer: game.jarchive_game.final_jeopardy.answer
    }

    {:ok,
     game
     |> zero_out_negative_scores()
     |> Map.put(:clue, clue)
     |> Map.put(:round, :final_jeopardy)
     |> FSM.to_state(FSM.AwaitingFinalJeopardyWagers)}
  end
end
