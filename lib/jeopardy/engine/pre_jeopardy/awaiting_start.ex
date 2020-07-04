defmodule Jeopardy.Engine.PreJeopardy.AwaitingStart do
  use Jeopardy.Engine

  @round_status "awaiting_start"
  @next_round "selecting_trebek"

  def handle(%{event: :start_game, data: data}, %{game: game} = state) do
    # TODO check if enough players
    game = Jeopardy.JArchive.load_into_game(game)
    Jeopardy.GameState.update_round_status(game.code, @round_status, @next_round)
  end

  def handle(%{event: :player_joined, data: data}, %{game: game} = state) do
    # add the player
  end

  def handle(%{event: :player_exited, data: data}, %{game: game} = state) do
    # remove the player
  end
end
