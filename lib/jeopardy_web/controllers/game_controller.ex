defmodule JeopardyWeb.GameController do
  use JeopardyWeb, :controller
  alias Jeopardy.Games
  require Logger

  def create(conn, _params) do
    case Games.create() do
      {:ok, game} ->
        :telemetry.execute([:j, :games, :created], %{c: 1})

        Jeopardy.Email.notify_new_game(game)
        |> Jeopardy.Mailer.deliver_later()

        {:ok, _pid} =
          DynamicSupervisor.start_child(
            Jeopardy.DynamicSupervisor,
            {Jeopardy.Engine, name: via_tuple(game.id)}
          )

        conn
        |> put_session(:code, game.code)
        # |> configure_session(renew: true)
        |> redirect(to: "/games/#{game.code}/tv")

      {:error, _} ->
        conn
        |> put_flash(:error, "Sorry, there was an issue creating your game")
        |> redirect(to: "/")
    end
  end

  defp via_tuple(id) do
    {:via, Registry, {Jeopardy.Registry, id}}
  end
end
