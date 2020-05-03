defmodule JeopardyWeb.PageController do
  use JeopardyWeb, :controller
  alias Jeopardy.Games
  alias Jeopardy.Games.Game
  alias Jeopardy.Games.Login
  require Logger

  def index(conn, _params) do
    conn
    # |> clear_session
    # |> configure_session(drop: true)
    |> assign(:changeset, Login.changeset())
    |> render("index.html")
  end

  def join(conn, %{"login" => %{"name" => name, "code" => code} = login}) do
    code = String.upcase(code)

    with {:ok, changeset} <- Login.validate(login),
         %Game{} <- Games.get_by_code(code) do
      conn
      |> put_flash(:info, "Welcome back!")
      |> put_session(:name, name)
      |> put_session(:code, code)
      |> redirect(to: "/games/#{code}")
    else
      {:error, changeset} -> conn |> render("index.html", changeset: changeset)
      nil ->
        conn
        |> put_flash(:info, "Sorry, that game doesn't exist")
        |> redirect(to: "/")
    end
  end
end
