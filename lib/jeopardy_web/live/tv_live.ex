defmodule JeopardyWeb.TvLive do
  use JeopardyWeb, :live_view

  def mount(params, _session, socket) do
    {:ok, game} = Jeopardy.GameServer.get_game(params["code"])

    if connected?(socket),
      do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, "games:#{params["code"]}")

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
      <a :if={Enum.count(@players) >= 2} href="#" class="btn btn-primary">
        Start Game
      </a>
    </div>
    """
  end

  def handle_info({:player_added, name}, socket) do
    {:noreply, assign(socket, players: [name | socket.assigns.players])}
  end

  def handle_info({:player_removed, name}, socket) do
    {:noreply, assign(socket, players: List.delete(socket.assigns.players, name))}
  end

  def handle_info({:status_changed, _status}, socket) do
    {:noreply, socket}
  end
end
