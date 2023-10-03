defmodule JeopardyWeb.AssignTrebekController do
  use JeopardyWeb, :controller

  def assign(conn, %{"code" => code}) do
    {:ok, game} = Jeopardy.GameServer.get_game(code)

    conn =
      if get_session(conn, :code) == code && get_session(conn, :name) == game.trebek,
        do: put_session(conn, :role, :trebek),
        else: conn

    redirect(conn, to: ~p"/games/#{code}")
  end
end
