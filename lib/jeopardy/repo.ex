defmodule Jeopardy.Repo do
  use Ecto.Repo,
    otp_app: :jeopardy,
    adapter: Ecto.Adapters.Postgres
end
