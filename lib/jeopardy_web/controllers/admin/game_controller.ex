defmodule JeopardyWeb.Admin.GameController do
  use JeopardyWeb, :controller
  alias Jeopardy.Admin
  alias Jeopardy.Games
  require Logger

  def index(conn, _params) do
    conn
    |> assign(:games, Admin.all_games())
    |> render(:index)
  end

  def show(conn, %{"id" => id}) do
    game = Games.get_game!(id)

    conn
    |> assign(:game, game)
    |> assign(:players, game.players)
    |> assign(:clue, Jeopardy.Games.Game.current_clue(game))
    |> render(:show)
  end
end
