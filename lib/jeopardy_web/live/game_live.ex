defmodule JeopardyWeb.GameLive do
  @moduledoc false
  use JeopardyWeb, :live_view

  alias Jeopardy.FSM
  alias Jeopardy.FSM.Messages.PlayAgain
  alias Jeopardy.FSM.Messages.PlayerRemoved
  alias Jeopardy.FSM.Messages.StatusChanged

  def mount(%{"code" => code}, session, socket) do
    {:ok, game} = Jeopardy.GameServer.get_game(code)

    if connected?(socket),
      do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, "games:#{code}")

    socket =
      with ^code <- Map.get(session, "code"),
           name = Map.get(session, "name"),
           true <- name in Map.keys(game.players) do
        role = if name == game.trebek, do: :trebek, else: :contestant
        assign(socket, name: name, role: role)
      else
        _ -> assign(socket, name: nil, role: :tv)
      end

    {:ok, assign(socket, code: code, state: game.fsm.state), layout: {JeopardyWeb.Layouts, :game_app}}
  end

  def render(assigns) do
    ~H"""
    <.live_component
      module={FSM.to_component(@state, @role)}
      id="c-id"
      code={@code}
      name={@name}
      role={@role}
    />
    """
  end

  def handle_info(%FSM.Messages.TrebekSelected{trebek: name}, socket) do
    if name == socket.assigns.name,
      do: {:noreply, assign(socket, role: :trebek)},
      else: {:noreply, socket}
  end

  def handle_info(%StatusChanged{to: state}, socket) do
    {:noreply, assign(socket, state: state)}
  end

  def handle_info(%PlayAgain{}, socket) do
    {:noreply, redirect(socket, to: ~p"/games/#{socket.assigns.code}")}
  end

  def handle_info(%PlayerRemoved{name: name} = msg, socket) do
    if name == socket.assigns.name do
      {:noreply, socket |> put_flash(:warning, "You've been removed from the game") |> redirect(to: ~p"/")}
    else
      send_update(FSM.to_component(socket.assigns.state, socket.assigns.role),
        id: "c-id",
        game_server_message: msg
      )

      {:noreply, socket}
    end
  end

  def handle_info(data, socket) do
    send_update(FSM.to_component(socket.assigns.state, socket.assigns.role),
      id: "c-id",
      game_server_message: data
    )

    {:noreply, socket}
  end
end
