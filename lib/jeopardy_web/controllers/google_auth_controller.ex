defmodule JeopardyWeb.GoogleAuthController do
  use JeopardyWeb, :controller
  require Logger

  @doc """
  `index/2` handles the callback from Google Auth API redirect.
  """
  def index(conn, %{"code" => code}) do
    {:ok, token} = ElixirAuthGoogle.get_token(code, conn)
    Logger.warn("[xxx] Got token back from google: #{inspect(token)}")

    {:ok, profile} = ElixirAuthGoogle.get_user_profile(token.access_token)

    Logger.warn("[xxx] Got profile back from google: #{inspect(profile)}")

    with {:ok, %{email: "ryoung786@gmail.com"}} <-
           ElixirAuthGoogle.get_user_profile(token.access_token) do
      conn
      |> put_session(:admin, true)
      |> redirect(to: "/admin")
    else
      resp ->
        Logger.warn("[xxx] OAUTH got back #{inspect(resp)}")

        conn
        |> send_resp(403, "Forbidden")
    end
  end
end
