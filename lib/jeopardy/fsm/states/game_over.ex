defmodule Jeopardy.FSM.GameOver do
  @moduledoc false
  use Jeopardy.FSM.State

  alias Jeopardy.FSM
  alias Jeopardy.FSM.Messages.FinalScoresRevealed
  alias Jeopardy.Game
  alias Jeopardy.Timers

  @timer_seconds 2

  @impl true
  def initial_data(game) do
    {:ok, tref} =
      :timer.apply_after(:timer.seconds(@timer_seconds), Jeopardy.GameServer, :action, [
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
  def valid_actions, do: ~w/revealed play_again/a

  @impl true
  def handle_action(:play_again, %Game{} = game, _data), do: play_again(game)

  def handle_action(:revealed, game, _data), do: mark_revealed(game)

  defp mark_revealed(game) do
    data = game.fsm.data
    :timer.cancel(data.tref)
    curr = Enum.at(data.contestants, data.index)

    # move to the next state: nil -> name -> wager -> answer -> nil/game_over
    {new_state, value} =
      case data.state do
        nil -> {:name, curr.name}
        :name -> {:wager, curr.final_jeopardy_wager}
        :wager -> {:answer, curr.final_jeopardy_answer || "No answer"}
        :answer -> {nil, nil}
      end

    new_state = if new_state == nil && data.index + 1 >= Enum.count(data.contestants), do: :game_over, else: new_state

    # Let the clients know to reveal the next state
    game =
      game.fsm.data.state
      |> put_in(new_state)
      |> FSM.broadcast(%FinalScoresRevealed{state: new_state, value: value})

    # if the game isn't over, we need to reset the timer
    game =
      if new_state == :game_over do
        game
      else
        {:ok, tref} =
          :timer.apply_after(:timer.seconds(@timer_seconds), Jeopardy.GameServer, :action, [
            game.code,
            :revealed,
            nil
          ])

        game = put_in(game.fsm.data.expires_at, Timers.add(@timer_seconds))
        put_in(game.fsm.data.tref, tref)
      end

    # if we've finished revealing a contestant, then we need to update their score
    # based on if they got the final jeopardy clue right or wrong
    if new_state in [nil, :game_over] do
      delta =
        if curr.final_jeopardy_correct?,
          do: curr.final_jeopardy_wager,
          else: -1 * curr.final_jeopardy_wager

      {:ok,
       game.fsm.data.index
       |> put_in(data.index + 1)
       |> Game.update_contestant_score(curr.name, delta, curr.final_jeopardy_correct?)}
    else
      {:ok, game}
    end
  end

  defp play_again(game) do
    game = %Game{code: game.code, players: game.players}

    with {:ok, game} <- FSM.AwaitingPlayers.load_game(game, :random) do
      {:ok, FSM.broadcast(game, %FSM.Messages.PlayAgain{})}
    end
  end
end
