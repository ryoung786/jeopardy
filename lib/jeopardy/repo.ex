defmodule Jeopardy.Repo do
  use Ecto.Repo,
    otp_app: :jeopardy,
    adapter: Ecto.Adapters.SQLite3
end
