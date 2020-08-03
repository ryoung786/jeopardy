# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :jeopardy,
  ecto_repos: [Jeopardy.Repo]

config :jeopardy, env: Mix.env()

# Configures the endpoint
config :jeopardy, JeopardyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "XbCnPpxwHXFVER5/cDxCSCiHIwUFlcc9AAT1XlZtAxWxkHKeKdG3zDt3JeJOJ5BL",
  render_errors: [view: JeopardyWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Jeopardy.PubSub,
  live_view: [signing_salt: "wr7JpKlV"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :jeopardy, :pow,
  user: Jeopardy.Users.User,
  repo: Jeopardy.Repo,
  extensions: [PowResetPassword, PowEmailConfirmation],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  mailer_backend: MyAppWeb.Pow.Mailer,
  web_module: JeopardyWeb

config :jeopardy, :pow_assent,
  providers: [
    google: [
      client_id: System.get_env("GOOGLE_CLIENT_ID"),
      client_secret: System.get_env("GOOGLE_CLIENT_SECRET"),
      strategy: Assent.Strategy.Google
    ],
    facebook: [
      client_id: System.get_env("FACEBOOK_CLIENT_ID"),
      client_secret: System.get_env("FACEBOOK_CLIENT_SECRET"),
      strategy: Assent.Strategy.Facebook
    ]
  ]

config :jeopardy, Jeopardy.Mailer,
  adapter: Bamboo.SendGridAdapter,
  server: "smtp.domain",
  hostname: "ryoung.info",
  port: 1025,
  api_key: System.get_env("SMTP_API_KEY"),
  email_recipient: System.get_env("EMAIL_NOTIFICATION_RECIPIENT"),
  tls: :if_available,
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
  ssl: false,
  retries: 1,
  no_mx_lookups: false,
  auth: :if_available

config :jeopardy, Jeopardy.BIReplication,
  # 1 hour
  frequency: 1 * 60 * 60 * 1000,
  bucket: "jeopardy_ryoung_test"

config :jeopardy, Jeopardy.Cron.CullOldRecords,
  # daily
  frequency: 24 * 60 * 60 * 1000

config :jeopardy, gtag: false

# milliseconds
config :jeopardy, early_buzz_penalty: 1_000

if Mix.env() != :prod do
  config :git_hooks,
    auto_install: true,
    verbose: true,
    hooks: [
      pre_commit: [
        tasks: [
          "mix format --check-formatted"
        ]
      ]
    ]
end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
