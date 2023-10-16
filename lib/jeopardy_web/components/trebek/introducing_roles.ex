defmodule JeopardyWeb.Components.Trebek.IntroducingRoles do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <p>Congratulations, you'll be hosting this round of Jeopardy!</p>

      <button class="btn btn-primary" phx-click="continue" phx-target={@myself}>
        Ready
      </button>
    </div>
    """
  end

  def handle_event("continue", _params, socket) do
    Jeopardy.GameServer.action(socket.assigns.code, :continue)
    {:noreply, socket}
  end
end
