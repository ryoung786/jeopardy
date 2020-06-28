defmodule Jeopardy.Email do
  use Bamboo.Phoenix, view: JeopardyWeb.EmailView

  def notify_new_game(%Jeopardy.Games.Game{} = game) do
    recipient = Application.fetch_env!(:jeopardy, Jeopardy.Mailer)[:email_recipient]

    url =
      case Application.get_env(:jeopardy, :env) do
        :prod -> "https://jeopardy.ryoung.info/admin/games/#{game.id}"
        _ -> "http://localhost:4000/admin/games/#{game.id}"
      end

    new_email()
    |> to(recipient)
    |> from("notifications@ryoung.info")
    |> subject("[Jeopardy] New Game: " <> game.code)
    |> text_body("New game: " <> url)
    |> html_body("New game: <a href=\"#{url}\">#{url}</a>")
  end
end
