use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :jeopardy, Jeopardy.Repo,
  username: "postgres",
  password: "postgres",
  database: "jeopardy_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :jeopardy, JeopardyWeb.Endpoint,
  http: [port: 4002],
  server: false

config :goth,
  json:
    "{\"type\":\"service_account\",\"project_id\":\"jeopardy-281015\",\"private_key_id\":\"xxxx\",\"private_key\":\"xxxx\",\"client_email\":\"gigalixir@xxxx.iam.gserviceaccount.com\",\"client_id\":\"123\",\"auth_uri\":\"https:\/\/accounts.google.com\/o\/oauth2\/auth\",\"token_uri\":\"https:\/\/oauth2.googleapis.com\/token\",\"auth_provider_x509_cert_url\":\"https:\/\/www.googleapis.com\/oauth2\/v1\/certs\",\"client_x509_cert_url\":\"xxxx\"}"

# Print only warnings and errors during test
config :logger, level: :warn
