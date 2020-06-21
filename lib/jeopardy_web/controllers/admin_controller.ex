defmodule JeopardyWeb.AdminController do
  use JeopardyWeb, :controller
  require Logger

  def index(conn, _params) do
    conn
    |> text("hi this is the admin view")
  end
end
