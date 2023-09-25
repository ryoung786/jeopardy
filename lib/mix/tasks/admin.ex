defmodule Mix.Tasks.Admin do
  use Mix.Task

  @moduledoc """
  Given an email, makes that user (if they exist) an admin.

  ## Examples:
      $ mix admin foo@test.com
  """
  @shortdoc "Makes a user an admin"

  def run([email | _]) do
    Mix.Task.run("app.start")

    case Jeopardy.Accounts.get_user_by_email(email) do
      %Jeopardy.Accounts.User{} = user ->
        Jeopardy.Accounts.make_admin(user)
        IO.puts("#{email} is now an admin")

      _ ->
        IO.puts("No users with email #{email} exist.")
    end
  end
end
