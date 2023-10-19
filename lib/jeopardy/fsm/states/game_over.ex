defmodule Jeopardy.FSM.GameOver do
  @moduledoc false
  use Jeopardy.FSM.State

  alias Jeopardy.FSM
  alias Jeopardy.Game

  @impl true
  def initial_data(game) do
    %{contestants_remaining: Game.contestants_lowest_to_highest_score(game, sort: :alphabetical)}
  end

  @impl true
  def valid_actions, do: ~w/revealed_contestant play_again/a

  @impl true
  def handle_action(:play_again, %Game{} = game, _data), do: play_again(game)

  def handle_action(:revealed_contestant, game, _data), do: mark_revealed(game)

  defp mark_revealed(game) do
    [revealed | remaining] = game.fsm.data.contestants_remaining

    delta =
      if revealed.final_jeopardy_correct?,
        do: revealed.final_jeopardy_wager,
        else: -1 * revealed.final_jeopardy_wager

    game = Game.update_contestant_score(game, revealed.name, delta)

    FSM.broadcast(
      game,
      %FSM.Messages.ScoreUpdated{contestant_name: revealed.name, from: revealed.score, to: revealed.score + delta}
    )

    {:ok, put_in(game.fsm.data.contestants_remaining, remaining)}
  end

  defp play_again(game) do
    game = %Game{code: game.code, players: game.players}

    with {:ok, game} <- FSM.AwaitingPlayers.load_game(game, :random) do
      {:ok, FSM.broadcast(game, %FSM.Messages.PlayAgain{})}
    end
  end
end
