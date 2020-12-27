defmodule JeopardyWeb.Router do
  use JeopardyWeb, :router
  use Pow.Phoenix.Router
  use Pow.Extension.Phoenix.Router, extensions: [PowResetPassword]
  use PowAssent.Phoenix.Router
  import Phoenix.LiveDashboard.Router
  require Logger
  alias Jeopardy.Games
  alias Jeopardy.Drafts

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {JeopardyWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api, do: plug(:accepts, ["json"])
  pipeline :games, do: plug(:ensure_game_exists)
  pipeline :ensure_name, do: plug(:ensure_name_exists)

  pipeline :admin do
    plug(:ensure_admin)
    plug :put_root_layout, {JeopardyWeb.LayoutView, :admin}
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated, error_handler: Pow.Phoenix.PlugErrorHandler
  end

  pipeline :skip_csrf_protection do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :authorized, do: plug(:ensure_admin_or_owner)

  scope "/" do
    pipe_through :skip_csrf_protection

    pow_assent_authorization_post_callback_routes()
  end

  scope "/" do
    pipe_through :browser

    pow_routes()
    pow_assent_routes()
    pow_extension_routes()
  end

  scope "/", JeopardyWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/", PageController, :join
    post "/games", GameController, :create
    get "/privacy-policy", PageController, :privacy_policy

    live "/games", GamesLive, :index

    scope "/games/:code" do
      pipe_through :games
      live "/tv", TvLive, layout: {JeopardyWeb.LayoutView, :tv}
      live "/stats", StatsLive, layout: {JeopardyWeb.LayoutView, :stats}

      pipe_through :ensure_name
      live "/", ContestantLive, layout: {JeopardyWeb.LayoutView, :contestant}
      live "/trebek", TrebekLive, layout: {JeopardyWeb.LayoutView, :trebek}
    end
  end

  pipeline :accounts do
    # plug(:ensure_admin)
    plug :put_root_layout, {JeopardyWeb.LayoutView, :accounts}
  end

  scope "/account", JeopardyWeb.Accounts.Drafts do
    pipe_through [:browser, :protected, :accounts]

    live "/games", GameLive.Index, :index
    live "/games/new", GameLive.Index, :new

    pipe_through :authorized
    live "/games/:id/edit", GameLive.Edit, :edit
    live "/games/:id/edit/:round", GameLive.Edit, :edit

    live "/games/:id/edit/final-jeopardy", GameLive.Edit.FinalJeopardy, :edit
    live "/games/:id/edit/:round", GameLive.Edit.Jeopardy, :edit
    live "/games/:id/edit/:round/clue/:clue_id", GameLive.Edit.Jeopardy, :edit_clue
    live "/games/:id/edit/:round/category/:category_id", GameLive.Edit.Jeopardy, :edit_category

    live "/games/:id", GameLive.Show, :show
    live "/games/:id/show/edit", GameLive.Show, :edit
  end

  scope "/admin", JeopardyWeb.Admin, as: :admin do
    pipe_through [:browser, :protected, :admin]

    get "/", GameController, :index
    live_dashboard "/dashboard", metrics: JeopardyWeb.Telemetry
    resources "/games", GameController, only: [:index, :show]
    resources "/players", PlayerController, only: [:show]
    resources "/clues", ClueController, only: [:show]
  end

  def ensure_game_exists(conn, _opts) do
    case Games.get_by_code(conn.path_params["code"]) do
      nil ->
        conn |> put_flash(:info, "Game not found") |> redirect(to: "/") |> halt()

      game ->
        Logger.metadata(game_id: game.id)
        Logger.metadata(game_code: game.code)

        conn
        |> put_session(:game_id, game.id)
        |> assign(:game, game)
    end
  end

  defp ensure_admin(conn, _opts) do
    admin_user_emails = Application.fetch_env!(:jeopardy, :admin)[:ADMIN_USER_EMAILS]

    if conn.assigns.current_user.email in admin_user_emails do
      conn
    else
      conn
      |> put_status(404)
      |> put_view(JeopardyWeb.ErrorView)
      |> render(:"404")
      |> halt()
    end
  end

  defp ensure_name_exists(conn, _opts) do
    case get_session(conn, :name) do
      nil ->
        conn |> put_flash(:info, "Please enter your name") |> redirect(to: "/") |> halt()

      name ->
        Logger.metadata(player_name: name)
        conn
    end
  end

  defp ensure_admin_or_owner(conn, _opts) do
    with %Drafts.Game{} = game <- Drafts.get_game(conn.params["id"]),
         true <- is_admin_or_owner(conn.assigns.current_user, game) do
      conn
    else
      _ -> halt_with_status(conn, 404)
    end
  end

  defp is_admin_or_owner(user, game),
    do: is_admin(user) || (game.owner_type == "user" && game.owner_id == user.id)

  defp is_admin(user),
    do: user.email in Application.fetch_env!(:jeopardy, :admin)[:ADMIN_USER_EMAILS]

  defp halt_with_status(conn, status) do
    conn
    |> put_status(status)
    |> put_view(JeopardyWeb.ErrorView)
    |> render(:"#{status}")
    |> halt()
  end

  if Mix.env() == :dev, do: forward("/sent_emails", Bamboo.SentEmailViewerPlug)
end
