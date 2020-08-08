defmodule JeopardyWeb.Pow.Plug do
  use Pow.Plug.Base
  alias Jeopardy.Users.User
  require Logger
  @session_key :pow_user_token
  @salt "AF1QipM7qUGuu9LERcWZ2kcq7LxL8Lssa7IAdfiUdnou"
  @max_age 86400

  def fetch(conn, _config) do
    conn = Plug.Conn.fetch_session(conn)
    token = Plug.Conn.get_session(conn, @session_key)

    JeopardyWeb.Endpoint
    |> Phoenix.Token.verify(@salt, token, max_age: @max_age)
    |> maybe_load_user(conn)
  end

  defp maybe_load_user({:ok, user_id}, conn), do: {conn, Jeopardy.Repo.get(User, user_id)}
  defp maybe_load_user({:error, _any}, conn), do: {conn, nil}

  def create(conn, user, _config) do
    token = Phoenix.Token.sign(JeopardyWeb.Endpoint, @salt, user.id)

    conn =
      conn
      |> Plug.Conn.fetch_session()
      |> Plug.Conn.put_session(@session_key, token)

    {conn, user}
  end

  def delete(conn, _config) do
    conn
    |> Plug.Conn.fetch_session()
    |> Plug.Conn.delete_session(@session_key)
  end
end
