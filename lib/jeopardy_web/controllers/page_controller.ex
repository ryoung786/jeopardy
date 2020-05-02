defmodule JeopardyWeb.PageController do
  use JeopardyWeb, :controller
  alias Jeopardy.Games
  require Logger

  def index(conn, _params) do
    conn
    |> clear_session
    |> configure_session(drop: true)
    |> clear_session
    |> configure_session(drop: true)
    render(conn, "index.html")
  end

  def join(conn, %{"name" => name, "code" => code}) do
    game = Games.get_game!(code)
    Logger.info("INspectING game: #{inspect(game)}")

    with %{} <- Games.get_game!(code) do
      conn
      |> put_flash(:info, "Welcome back!")
      |> put_session(:name, name)
      |> put_session(:code, code)
      # |> configure_session(renew: true)
      |> redirect(to: "/games/#{code}")
    else
      _ ->
        conn
        |> put_flash(:error, "Room doesn't exist")
        |> redirect(to: "/")
    end
  end
end
