defmodule JeopardyWeb.Components.Trebek.IntroducingRoles do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[1fr_auto] min-h-screen">
      <.trebek_clue>Congratulations, you'll be hosting this round of Jeopardy!</.trebek_clue>

      <div class="p-4 grid">
        <button class="btn btn-primary" phx-click="continue" phx-target={@myself}>
          Ready
        </button>
      </div>
    </div>
    """
  end

  def handle_event("continue", _params, socket) do
    Jeopardy.GameServer.action(socket.assigns.code, :continue)
    {:noreply, socket}
  end
end
