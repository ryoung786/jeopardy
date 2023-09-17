defmodule Jeopardy.FSM.ReadingFinalJeopardyClue do
  @moduledoc """
  reading final jeopardy clue -> grading final jeopardy answers
  """

  use Jeopardy.FSM.State

  @impl true
  def valid_actions(), do: ~w/answered time_expired/a

  @impl true
  def handle_action(:answered, game, {contestant_name, response}),
    do: answer(game, contestant_name, response)

  def handle_action(:time_expired, game, _), do: time_expired(game)

  defp answer(game, name, response) do
    with :ok <- validate_contestant_exists(game, name) do
      game = put_in(game.contestants[name].final_jeopardy_answer, response)

      if Enum.any?(Map.values(game.contestants), &(&1.final_jeopardy_answer == nil)),
        do: {:ok, game},
        else: {:ok, FSM.to_state(game, FSM.GradingFinalJeopardyAnswers)}
    end
  end

  defp time_expired(game) do
    {:ok, FSM.to_state(game, FSM.GradingFinalJeopardyAnswers)}
  end

  defp validate_contestant_exists(game, name) do
    if Map.has_key?(game.contestants, name),
      do: :ok,
      else: {:error, :contestant_does_not_exist}
  end
end
