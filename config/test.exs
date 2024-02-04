import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :jeopardy, Jeopardy.Repo,
  database: Path.expand("../db/jeopardy_test.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :jeopardy, JeopardyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "zDyPsmqBBYgR4maOgl6sVgY1D8YfC5XSpxDAvq7xqXLGfDiNyhyEt6SboqWZ22eW",
  server: false

# In test we don't send emails.
config :jeopardy, Jeopardy.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :jeopardy, Jeopardy.JArchive, path: Path.expand("test/support/jarchive")
