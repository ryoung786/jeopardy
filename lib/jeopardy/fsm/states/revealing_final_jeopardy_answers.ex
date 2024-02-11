defmodule Jeopardy.FSM.RevealingFinalJeopardyAnswers do
  @moduledoc false
  use Jeopardy.FSM.State

  alias Jeopardy.FSM
  alias Jeopardy.FSM.Messages.FinalScoresRevealed
  alias Jeopardy.Game
  alias Jeopardy.GameServer
  alias Jeopardy.Timers

  @timer_seconds 4

  @impl true
  def initial_data(game) do
    {:ok, tref} =
      :timer.apply_after(:timer.seconds(@timer_seconds), GameServer, :action, [
        game.code,
        :revealed,
        nil
      ])

    %{
      expires_at: Timers.add(@timer_seconds),
      tref: tref,
      state: nil,
      contestants: Game.contestants_lowest_to_highest_score(game, sort: :alphabetical),
      index: 0
    }
  end

  @impl true
  def valid_actions, do: ~w/revealed/a

  @impl true
  def handle_action(:revealed, game, _data), do: mark_revealed(game)

  defp mark_revealed(game) do
    data = game.fsm.data
    :timer.cancel(data.tref)
    curr = Enum.at(data.contestants, data.index)

    # move to the next state: nil -> name -> wager -> answer -> nil
    {new_state, value} =
      case data.state do
        nil -> {:name, curr.name}
        :name -> {:wager, curr.final_jeopardy_wager}
        :wager -> {:answer, curr.final_jeopardy_answer || "No answer"}
        :answer -> {nil, nil}
      end

    if new_state == nil && data.index + 1 >= Enum.count(data.contestants) do
      # everything has been revealed

      game = update_score(game, curr)
      any_correct_answers? = Enum.any?(Map.values(game.contestants), & &1.final_jeopardy_correct?)

      if any_correct_answers?,
        do: {:ok, FSM.to_state(game, FSM.GameOver)},
        else: {:ok, FSM.to_state(game, FSM.RevealingCorrectFinalJeopardyAnswer)}
    else
      # Let the clients know to reveal the next state
      game =
        game.fsm.data.state
        |> put_in(new_state)
        |> FSM.broadcast(%FinalScoresRevealed{state: new_state, value: value})

      # reset the timer
      args = [game.code, :revealed, nil]
      {:ok, tref} = :timer.apply_after(:timer.seconds(@timer_seconds), GameServer, :action, args)

      game = put_in(game.fsm.data.expires_at, Timers.add(@timer_seconds))
      game = put_in(game.fsm.data.tref, tref)

      # if we've finished revealing a contestant, then we need to update their score
      # based on if they got the final jeopardy clue right or wrong
      if new_state == nil,
        do: {:ok, update_score(game, curr)},
        else: {:ok, game}
    end
  end

  defp update_score(game, contestant) do
    delta =
      if contestant.final_jeopardy_correct?,
        do: contestant.final_jeopardy_wager,
        else: -1 * contestant.final_jeopardy_wager

    game.fsm.data.index
    |> put_in(game.fsm.data.index + 1)
    |> Game.update_contestant_score(contestant.name, delta, contestant.final_jeopardy_correct?)
  end
end
