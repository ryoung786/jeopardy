defmodule JeopardyWeb.GameLive do
  use JeopardyWeb, :live_view

  def mount(params, _session, socket) do
    {:ok, game} = Jeopardy.GameServer.get_game(params["code"])

    {:ok,
     socket
     |> assign(players: game.players)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <ul>
        <li :for={player <- @players}><%= player %></li>
      </ul>
    </div>
    """
  end
end
