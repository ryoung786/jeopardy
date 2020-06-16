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
    # |> clear_session
    # |> configure_session(drop: true)
    |> assign(:changeset, Login.changeset())
    |> render("index.html")
  end

  def join(conn, %{"login" => %{"name" => name, "code" => code} = login}) do
    code = String.upcase(code)

    with {:ok, _changeset} <- Login.validate(login),
         %Game{} = g <- Games.get_by_code(code),
         :ok <- add_player(g, name) do
      conn
      |> put_session(:name, name)
      |> put_session(:code, code)
      |> put_session(:game_id, g.id)
      |> redirect(to: "/games/#{code}")
    else
      {:error, :name_taken} ->
        conn
        |> put_flash(:error, "Sorry, that name has already been taken")
        |> redirect(to: "/")

      {:error, :game_in_progress} ->
        conn
        |> put_flash(:error, "Sorry, that game is already in progress")
        |> redirect(to: "/")

      {:error, changeset} ->
        conn |> render("index.html", changeset: changeset)

      nil ->
        conn
        |> put_flash(:error, "Sorry, that game doesn't exist")
        |> redirect(to: "/")
    end
  end

  defp add_player(%Game{round_status: "awaiting_start"} = game, name) do
    with false <- Games.get_all_players(game) |> Enum.map(& &1.name) |> Enum.member?(name),
         {:ok, _} <-
           Ecto.build_assoc(game, :players, %{name: name})
           |> Jeopardy.Repo.insert() do
      Phoenix.PubSub.broadcast(Jeopardy.PubSub, game.code, %{event: :player_joined, name: name})
    else
      true -> {:error, :name_taken}
    end
  end

  defp add_player(_, _), do: {:error, :game_in_progress}
end
