defmodule JeopardyWeb.GameController do
  use JeopardyWeb, :controller
  alias Jeopardy.Games
  require Logger

  def create(conn, _params) do
    game = Games.create_game()
    Logger.info("INspectING CREATE game: #{inspect(game)}")
    conn
    |> put_session(:code, game.code)
    # |> configure_session(renew: true)
    |> redirect(to: "/games/#{game.code}/tv")
  end
end
