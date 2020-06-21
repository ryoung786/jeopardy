defmodule JeopardyWeb.Admin.PlayerController do
  use JeopardyWeb, :controller
  alias Jeopardy.Admin
  require Logger

  def show(conn, %{"id" => id}) do
    player = Admin.get_player(id)

    conn
    |> assign(:player, player)
    |> assign(:game, player.game)
    |> render(:show)
  end
end
