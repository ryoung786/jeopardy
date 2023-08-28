defmodule JeopardyWeb.Router do
  use JeopardyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {JeopardyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :require_game, do: plug(JeopardyWeb.Plugs.RequireGame)

  scope "/", JeopardyWeb do
    pipe_through :browser

    get "/", HomeController, :home
    post "/", HomeController, :join
    live "/games", GamesLive

    scope "/games/:code" do
      pipe_through [:require_game]
      live "/", GameLive
      live "/tv", TvLive
    end
  end

  if Application.compile_env(:jeopardy, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: JeopardyWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
