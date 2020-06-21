defmodule JeopardyWeb.AdminController do
  use JeopardyWeb, :controller
  alias Jeopardy.Admin
  require Logger

  def index(conn, _params) do
    conn
    |> assign(:games, Admin.all_games())
    |> render(:index)
  end
end
