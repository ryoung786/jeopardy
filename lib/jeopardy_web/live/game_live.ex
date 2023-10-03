defmodule JeopardyWeb.GameLive do
  use JeopardyWeb, :live_view

  alias Jeopardy.FSM

  def mount(%{"code" => code}, session, socket) do
    {:ok, game} = Jeopardy.GameServer.get_game(code)

    if connected?(socket),
      do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, "games:#{code}")

    socket =
      if Map.get(session, "code") == code do
        socket
        |> assign(name: Map.get(session, "name"))
        |> assign(role: Map.get(session, "role", :tv))
      else
        assign(socket, name: nil, role: :tv)
      end

    {:ok, assign(socket, code: code, state: game.fsm.state)}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={FSM.to_component(@state, @role)} id="c-id" code={@code} name={@name} />
    """
  end

  def handle_info({:trebek_selected, name}, socket) do
    if name == socket.assigns.name,
      do: {:noreply, redirect(socket, to: ~p"/games/#{socket.assigns.code}/trebek")},
      else: {:noreply, socket}
  end

  def handle_info({:status_changed, state}, socket) do
    {:noreply, assign(socket, state: state)}
  end

  def handle_info(data, socket) do
    send_update(FSM.to_component(socket.assigns.state, socket.assigns.role),
      id: "c-id",
      game_server_message: data
    )

    {:noreply, socket}
  end
end
