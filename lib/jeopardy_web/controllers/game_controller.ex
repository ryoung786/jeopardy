defmodule JeopardyWeb.GameController do
  use JeopardyWeb, :controller
  alias Jeopardy.Games
  require Logger

  def create(conn, _params) do
    case Games.create() do
      {:ok, game} ->
        conn
        |> put_session(:code, game.code)
        # |> configure_session(renew: true)
        |> redirect(to: "/games/#{game.code}/tv")

      {:error, _} ->
        conn
        |> put_flash(:error, "Sorry, there was an issue creating your game")
        |> redirect(to: "/")
    end
  end
end
