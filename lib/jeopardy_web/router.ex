defmodule JeopardyWeb.Router do
  use JeopardyWeb, :router
  import Phoenix.LiveDashboard.Router
  require Logger
  alias Jeopardy.Games

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {JeopardyWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api, do: plug(:accepts, ["json"])
  pipeline :admin, do: plug(:ensure_admin)
  pipeline :games, do: plug(:ensure_game_exists)

  scope "/", JeopardyWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/", PageController, :join
    post "/games", GameController, :create
    get "/auth/google/callback", GoogleAuthController, :index

    scope "/games/:code" do
      pipe_through :games
      live "/", GameLive, layout: {JeopardyWeb.LayoutView, :contestant}
      live "/tv", TvLive, layout: {JeopardyWeb.LayoutView, :tv}
      live "/trebek", TrebekLive, layout: {JeopardyWeb.LayoutView, :trebek}
      live "/stats", StatsLive, layout: {JeopardyWeb.LayoutView, :stats}
    end
  end

  scope "/admin", JeopardyWeb do
    pipe_through [:browser, :admin]

    get "/", AdminController, :index
    live_dashboard "/dashboard", metrics: JeopardyWeb.Telemetry
  end

  def ensure_game_exists(conn, _opts) do
    case Games.get_by_code(conn.path_params["code"]) do
      nil ->
        conn |> put_flash(:info, "Game not found") |> redirect(to: "/") |> halt()

      game ->
        assign(conn, :game, game)
    end
  end

  defp ensure_admin(conn, _opts) do
    case get_session(conn, :admin) do
      true ->
        conn

      _ ->
        conn
        |> redirect(external: ElixirAuthGoogle.generate_oauth_url(conn) <> "&prompt=consent")
        |> halt()
    end
  end
end
