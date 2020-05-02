defmodule JeopardyWeb.Router do
  use JeopardyWeb, :router
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

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", JeopardyWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/", PageController, :join
    post "/games", GameController, :create

    scope "/games/:code" do
      pipe_through :games
      live "/", GameLive
      live "/tv", TvLive
    end

    # resources "/games", GameController, only: [:create, :show]
  end

  pipeline :games do
    plug :ensure_game_exists
  end

  def ensure_game_exists(conn, _opts) do
    case Games.get_game!(conn.path_params["code"]) do
      nil ->
        conn |> put_flash(:info, "Game not found") |> redirect(to: "/") |> halt()
      game ->
        assign(conn, :game, game)
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", JeopardyWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: JeopardyWeb.Telemetry
    end
  end
end
