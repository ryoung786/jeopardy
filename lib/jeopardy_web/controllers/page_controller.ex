defmodule JeopardyWeb.PageController do
  use JeopardyWeb, :controller
  alias Jeopardy.Games
  alias Jeopardy.Games.Game
  alias Jeopardy.Games.Login
  require Logger

  def index(conn, _params) do
    :telemetry.execute([:metrics_demo, :render], %{
      c: 1,
      controller: "PageController",
      action: "index"
    })

    :telemetry.execute([:metrics_demo, :foo], %{baz: 3, bar: 1})
    :telemetry.execute([:metrics_demo, :test], %{bar: "hello"})

    conn
    |> assign(:changeset, Login.changeset())
    |> render("index.html")
  end

  def join(conn, %{"login" => %{"name" => name, "code" => code} = login}) do
    code = String.upcase(code)

    with {:ok, _changeset} <- Login.validate(login),
         %Game{id: game_id} = g <- Games.get_by_code(code) do
      case get_session(conn) do
        %{"name" => ^name, "code" => ^code, "game_id" => ^game_id} ->
          redirect(conn, to: "/games/#{code}")

        _ ->
          case Jeopardy.GameEngine.event(:add_player, %{player_name: name}, g.id) do
            :ok ->
              conn
              |> put_session(:name, name)
              |> put_session(:code, code)
              |> put_session(:game_id, g.id)
              |> redirect(to: "/games/#{code}")

            {:error, :name_taken} ->
              conn
              |> put_flash(:error, "Sorry, that name has already been taken")
              |> redirect(to: "/")

            {:error, :game_in_progress} ->
              conn
              |> put_flash(:error, "Sorry, that game is already in progress")
              |> redirect(to: "/")
          end
      end
    else
      {:error, changeset} ->
        conn |> render("index.html", changeset: changeset)

      nil ->
        conn
        |> put_flash(:error, "Sorry, that game doesn't exist")
        |> redirect(to: "/")
    end
  end

  def privacy_policy(conn, _params) do
    conn
    |> render("privacy_policy.html")
  end
end
