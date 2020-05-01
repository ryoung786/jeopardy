defmodule JeopardyWeb.PageController do
  use JeopardyWeb, :controller

  def index(conn, _params) do
    conn
    |> clear_session
    |> configure_session(drop: true)
    |> clear_session
    |> configure_session(drop: true)
    render(conn, "index.html")
  end
end
