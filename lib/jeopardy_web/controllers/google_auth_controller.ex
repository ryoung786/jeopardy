defmodule JeopardyWeb.GoogleAuthController do
  use JeopardyWeb, :controller
  require Logger

  @doc """
  `index/2` handles the callback from Google Auth API redirect.
  """
  def index(conn, %{"code" => code}) do
    admin_user = Application.fetch_env!(:jeopardy, :admin)[:ADMIN_USER]

    {:ok, token} = ElixirAuthGoogle.get_token(code, conn)

    with {:ok, %{email: ^admin_user}} <-
           ElixirAuthGoogle.get_user_profile(token.access_token) do
      conn
      |> put_session(:admin, true)
      |> redirect(to: "/admin")
    else
      _ -> send_resp(conn, 403, "Forbidden")
    end
  end
end
