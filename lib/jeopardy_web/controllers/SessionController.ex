defmodule JeopardyWeb.SessionController do
  use JeopardyWeb, :controller

  def create(conn, %{"name" => name}) do
    conn
    |> put_flash(:info, "Welcome back!")
    |> put_session(:name, name)
    |> configure_session(renew: true)
    |> redirect(to: "/buzz")
  end
end
