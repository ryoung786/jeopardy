defmodule Jeopardy.FSM.PreJeopardy.AwaitingStart do
  alias Jeopardy.GameState
  alias Jeopardy.Games.Game

  def handle(_, _, %{game: game, audience: player_names}) do
    # guard if not enough players
    game = Jeopardy.JArchive.load_into_game(game)
    player_names |> Enum.each(fn name -> add_player(game, name) end)
    GameState.update_round_status(game.code, "awaiting_start", "selecting_trebek")
  end

  defp add_player(%Game{} = game, name) do
    Ecto.build_assoc(game, :players, %{name: name})
    |> Jeopardy.Repo.insert()
  end
end
