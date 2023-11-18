defmodule JeopardyWeb.GameLive do
  @moduledoc false
  use JeopardyWeb, :live_view

  alias Jeopardy.FSM
  alias Jeopardy.FSM.Messages.PlayAgain
  alias Jeopardy.FSM.Messages.PlayerRemoved
  alias Jeopardy.FSM.Messages.ScoreUpdated
  alias Jeopardy.FSM.Messages.StatusChanged
  alias JeopardyWeb.Components.Trebek.TrebekAdminPanel

  on_mount {JeopardyWeb.UserAuth, :mount_current_user}

  @layouts %{
    tv: {JeopardyWeb.Layouts, :tv_app},
    trebek: {JeopardyWeb.Layouts, :trebek_app},
    contestant: {JeopardyWeb.Layouts, :trebek_app}
  }

  def mount(%{"code" => code}, session, socket) do
    {:ok, game} = Jeopardy.GameServer.get_game(code)

    if connected?(socket),
      do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, "games:#{code}")

    role =
      cond do
        code == session["code"] && game.trebek == session["name"] -> :trebek
        code == session["code"] -> :contestant
        :else -> :tv
      end

    {:ok, assign(socket, code: code, name: session["name"], role: role, state: game.fsm.state), layout: @layouts[role]}
  end

  def render(assigns) do
    ~H"""
    <.live_component
      :if={@role == :trebek}
      module={TrebekAdminPanel}
      id="trebek-admin-panel"
      code={@code}
    />
    <.live_component module={FSM.to_component(@state, @role)} id="c-id" code={@code} name={@name} />
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

  def handle_info(%ScoreUpdated{} = msg, socket) do
    if :tv == socket.assigns.role,
      do: {:noreply, push_event(socket, "score-updated", Map.from_struct(msg))},
      else: {:noreply, socket}
  end

  def handle_info(data, socket) do
    send_update(FSM.to_component(socket.assigns.state, socket.assigns.role),
      id: "c-id",
      game_server_message: data
    )

    {:noreply, socket}
  end
end
