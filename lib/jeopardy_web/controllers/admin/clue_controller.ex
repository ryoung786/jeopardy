defmodule JeopardyWeb.Admin.ClueController do
  use JeopardyWeb, :controller
  alias Jeopardy.Admin
  require Logger

  def show(conn, %{"id" => id}) do
    clue = Admin.get_clue(id)

    conn
    |> assign(:clue, clue)
    |> assign(:game, clue.game)
    |> render(:show)
  end
end
