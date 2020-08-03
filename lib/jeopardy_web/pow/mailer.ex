defmodule MyAppWeb.Pow.Mailer do
  use Pow.Phoenix.Mailer
  # use Bamboo.Mailer, otp_app: :jeopardy

  # import Bamboo.Email

  @impl true
  def cast(%{user: _, subject: _, text: _, html: _} = details),
    do: Jeopardy.Email.reset_password(details)

  @impl true
  def process(email),
    do: Jeopardy.Mailer.deliver_now(email)
end
