# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :jeopardy,
  ecto_repos: [Jeopardy.Repo]

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

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
