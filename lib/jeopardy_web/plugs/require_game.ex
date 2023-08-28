defmodule JeopardyWeb.Plugs.RequireGame do
  use Phoenix.VerifiedRoutes, endpoint: JeopardyWeb.Endpoint, router: JeopardyWeb.Router

  def init(default), do: default

  def call(%Plug.Conn{params: %{"code" => code}} = conn, _opts) do
    if Jeopardy.GameServer.game_pid(code) == nil,
      do: conn |> Phoenix.Controller.redirect(to: ~p"/") |> Plug.Conn.halt(),
      else: conn
  end
end
