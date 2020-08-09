defmodule JeopardyWeb.GameController do
  use JeopardyWeb, :controller
  alias Jeopardy.Games
  alias Jeopardy.Drafts
  require Logger

  def create(conn, %{"game_id" => draft_game_id}) do
    draft_game = Drafts.get_game!(draft_game_id)
    handle(conn, Games.create_from_draft_game(draft_game))
  end

  def create(conn, params) do
    handle(conn, Games.create_from_random_jarchive())
    conn |> redirect(to: "/games")
  end

  defp handle(conn, create_result) do
    case create_result do
      {:ok, game} ->
        :telemetry.execute([:j, :games, :created], %{c: 1})

        Jeopardy.Email.notify_new_game(game)
        |> Jeopardy.Mailer.deliver_later()

        conn
        |> put_session(:code, game.code)
        |> redirect(to: "/games/#{game.code}/tv")

      {:error, _} ->
        conn
        |> put_flash(:error, "Sorry, there was an issue creating your game")
        |> redirect(to: "/games")
    end
  end
end
