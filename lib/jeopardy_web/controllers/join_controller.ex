defmodule JeopardyWeb.JoinController do
  use JeopardyWeb, :controller
  alias Jeopardy.Games
  alias Jeopardy.Games.Game
  alias Jeopardy.Games.Login
  require Logger

  def index(conn, %{"code" => code}) do
    :telemetry.execute([:metrics_demo, :render], %{
      c: 1,
      controller: "JoinController",
      action: "index"
    })

    conn
    |> assign(:changeset, Login.changeset())
    |> assign(:game, Games.get_by_code(code))
    |> render("index.html")
  end

  def join(conn, %{"login" => %{"name" => name}, "code" => code}) do
    login = %{"name" => name, "code" => code}

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
              |> redirect(to: Routes.join_path(conn, :index, code))

            {:error, :event_not_supported_by_game_state} ->
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
end
