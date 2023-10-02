defmodule JeopardyWeb.TvLive do
  use JeopardyWeb, :live_view

  alias Jeopardy.FSM

  def mount(params, _session, socket) do
    {:ok, game} = Jeopardy.GameServer.get_game(params["code"])

    if connected?(socket),
      do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, "games:#{params["code"]}")

    {:ok, assign(socket, players: game.players)}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={FSM.to_component(@state, :tv)} id="tv" {assigns} />
    """
  end

  def handle_info({:status_changed, state}, socket) do
    {:noreply, assign(socket, state: state)}
  end

  def handle_info(data, socket) do
    send_update(FSM.to_component(socket.assigns.state, :tv), id: "tv", game_server_message: data)
    {:noreply, socket}
  end
end
