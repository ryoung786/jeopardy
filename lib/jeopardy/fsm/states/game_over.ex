defmodule Jeopardy.FSM.GameOver do
  @moduledoc false
  use Jeopardy.FSM.State

  alias Jeopardy.FSM
  alias Jeopardy.Game

  @impl true
  def valid_actions, do: ~w/play_again/a

  @impl true
  def handle_action(:play_again, %Game{} = game, _data), do: play_again(game)

  defp play_again(game) do
    game = %Game{code: game.code, players: game.players}

    with {:ok, game} <- FSM.AwaitingPlayers.load_game(game, :random) do
      {:ok, FSM.broadcast(game, %FSM.Messages.PlayAgain{})}
    end
  end
end
