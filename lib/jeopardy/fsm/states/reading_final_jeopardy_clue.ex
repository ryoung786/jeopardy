defmodule Jeopardy.FSM.ReadingFinalJeopardyClue do
  @moduledoc """
  reading final jeopardy clue -> grading final jeopardy answers
  """

  use Jeopardy.FSM.State

  alias Jeopardy.FSM.Messages.FinalJeopardyAnswerSubmitted
  alias Jeopardy.FSM.Messages.TimerStarted
  alias Jeopardy.GameServer
  alias Jeopardy.Timers

  @timer_seconds 60

  @impl true
  def valid_actions, do: ~w/answered timer_started time_expired/a

  @impl true
  def handle_action(:answered, game, {contestant_name, response}), do: answer(game, contestant_name, response)

  def handle_action(:time_expired, game, _), do: time_expired(game)
  def handle_action(:timer_started, game, _), do: timer_started(game)

  defp answer(game, name, response) do
    with :ok <- validate_contestant_exists(game, name) do
      game = put_in(game.contestants[name].final_jeopardy_answer, response)

      if Enum.any?(Map.values(game.contestants), &(&1.final_jeopardy_answer == nil)) do
        FSM.broadcast(game, %FinalJeopardyAnswerSubmitted{name: name, response: response})
        {:ok, game}
      else
        :timer.cancel(game.fsm.data[:tref])
        {:ok, FSM.to_state(game, FSM.GradingFinalJeopardyAnswers)}
      end
    end
  end

  defp timer_started(game) do
    expires_at = Timers.add(@timer_seconds)
    FSM.broadcast(game, %TimerStarted{expires_at: expires_at})

    {:ok, tref} =
      :timer.apply_after(:timer.seconds(@timer_seconds), GameServer, :action, [
        game.code,
        :time_expired,
        nil
      ])

    {:ok, put_in(game.fsm.data, %{tref: tref, expires_at: expires_at})}
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
