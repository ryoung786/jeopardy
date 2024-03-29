defmodule JeopardyWeb.Plugs.RequireGame do
  @moduledoc false
  use JeopardyWeb, :verified_routes

  def init(default), do: default

  def call(%Plug.Conn{params: %{"code" => code}} = conn, _opts) do
    if code != String.upcase(code) do
      new_path = String.replace(conn.request_path, "/#{code}", "/#{String.upcase(code)}")
      conn |> Phoenix.Controller.redirect(to: new_path) |> Plug.Conn.halt()
    end

    if Jeopardy.GameServer.game_pid(code) == nil,
      do: conn |> Phoenix.Controller.redirect(to: ~p"/") |> Plug.Conn.halt(),
      else: conn
  end
end
