defmodule Jeopardy.FSM.GameOver do
  @moduledoc false
  use Jeopardy.FSM.State

  alias Jeopardy.FSM
  alias Jeopardy.FSM.Messages.FinalScoresRevealed
  alias Jeopardy.Game

  @impl true
  def initial_data(game) do
    %{contestants: Game.contestants_lowest_to_highest_score(game, sort: :alphabetical), index: 0}
  end

  @impl true
  def valid_actions, do: ~w/revealed_contestant play_again/a

  @impl true
  def handle_action(:play_again, %Game{} = game, _data), do: play_again(game)

  def handle_action(:revealed_contestant, game, _data), do: mark_revealed(game)

  defp mark_revealed(game) do
    contestants = game.fsm.data.contestants
    index = game.fsm.data.index
    contestant = Enum.at(contestants, index)

    delta =
      if contestant.final_jeopardy_correct?,
        do: contestant.final_jeopardy_wager,
        else: -1 * contestant.final_jeopardy_wager

    game = Game.update_contestant_score(game, contestant.name, delta)

    msg = %FSM.Messages.ScoreUpdated{
      contestant_name: contestant.name,
      from: contestant.score,
      to: contestant.score + delta
    }

    FSM.broadcast(game, msg)

    new_index = game.fsm.data.index + 1

    if new_index >= Enum.count(game.contestants) do
      FSM.broadcast(game, %FinalScoresRevealed{})
    end

    {:ok, put_in(game.fsm.data.index, game.fsm.data.index + 1)}
  end

  defp play_again(game) do
    game = %Game{code: game.code, players: game.players}

    with {:ok, game} <- FSM.AwaitingPlayers.load_game(game, :random) do
      {:ok, FSM.broadcast(game, %FSM.Messages.PlayAgain{})}
    end
  end
end
