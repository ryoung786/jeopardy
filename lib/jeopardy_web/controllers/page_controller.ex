defmodule JeopardyWeb.PageController do
  use JeopardyWeb, :controller
  alias Jeopardy.Games
  alias Jeopardy.Games.Game
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
    code = String.upcase(code)
    case Games.get_by_code(code) do
      nil ->
        conn
        |> put_flash(:info, "Sorry, that game doesn't exist")
        |> redirect(to: "/")
      %Game{} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:name, name)
        |> put_session(:code, code)
        |> redirect(to: "/games/#{code}")
    end
  end
end
