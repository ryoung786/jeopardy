defmodule JeopardyWeb.Router do
  use JeopardyWeb, :router

  import JeopardyWeb.UserAuth
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {JeopardyWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :game do
    plug JeopardyWeb.Plugs.RequireGame
    plug :put_root_layout, html: {JeopardyWeb.Layouts, :game_root}
  end

  scope "/", JeopardyWeb do
    pipe_through :browser

    get "/", HomeController, :home
    post "/", HomeController, :join
    get "/privacy-policy", HomeController, :privacy_policy
    live "/games", GamesLive

    scope "/join/:code" do
      pipe_through [:game]
      get "/", JoinController, :index
      post "/", JoinController, :join
    end

    scope "/games/:code" do
      pipe_through [:game]
      live "/", GameLive
    end
  end

  scope "/admin" do
    pipe_through [:browser, :require_admin_user]
    live_dashboard "/dashboard", metrics: JeopardyWeb.Telemetry
    forward "/mailbox", Plug.Swoosh.MailboxPreview
  end

  ## Authentication routes

  scope "/", JeopardyWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{JeopardyWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", JeopardyWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{JeopardyWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", JeopardyWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{JeopardyWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
