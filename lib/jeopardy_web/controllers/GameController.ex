defmodule JeopardyWeb.GameController do
  use JeopardyWeb, :controller
  alias Jeopardy.GameRoom

  def create(conn, _params) do
    game = GameRoom.new()
    conn
    |> put_session(:code, game.code)
    |> configure_session(renew: true)
    |> redirect(to: "/games/#{game.code}/tv")
  end

  def join(conn, %{"name" => name, "code" => code}) do
    conn
    |> put_flash(:info, "Welcome back!")
    |> put_session(:name, name)
    |> configure_session(renew: true)
    |> redirect(to: "/buzz")
  end
end
