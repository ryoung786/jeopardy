defmodule Jeopardy.FSM.GradingFinalJeopardyAnswers do
  @moduledoc """
  grading final jeopardy answers -> revealing final jeopardy answers
  """

  use Jeopardy.FSM.State

  alias Jeopardy.Game

  @impl true
  def valid_actions, do: ~w/submitted_grades/a

  @impl true
  def handle_action(:submitted_grades, game, correct_contestants), do: grade_answers(game, correct_contestants)

  defp grade_answers(game, correct_contestants) do
    with :ok <- validate_all_contestants_exist(game, correct_contestants) do
      game =
        Enum.reduce(correct_contestants, game, fn name, game ->
          Game.update_contestant_score(game, name, game.contestants[name].final_jeopardy_wager)
        end)

      {:ok, FSM.to_state(game, FSM.GameOver)}
    end
  end

  defp validate_all_contestants_exist(game, names) do
    if Enum.all?(names, &(&1 in Map.keys(game.contestants))),
      do: :ok,
      else: {:error, :contestant_does_not_exist}
  end
end
