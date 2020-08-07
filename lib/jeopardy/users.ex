defmodule Jeopardy.Users do
  import Ecto.Query, warn: false
  alias Jeopardy.Repo

  alias Jeopardy.Users.User

  def get_user!(id), do: Repo.get!(User, id)
end
