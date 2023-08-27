defmodule JeopardyWeb.GameLobbyLive do
  use JeopardyWeb, :live_view

  def mount(params, _session, socket) do
    {:ok, game} = Jeopardy.GameServer.get_game(params["code"])

    {:ok,
     socket
     |> assign(code: params["code"])
     |> assign(players: game.players)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <ul>
        <li :for={player <- @players}><%= player %></li>
      </ul>
      <a :if={Enum.count(@players) >= 2} href="#">
        "Start Game"
      </a>
    </div>
    """
  end
end
