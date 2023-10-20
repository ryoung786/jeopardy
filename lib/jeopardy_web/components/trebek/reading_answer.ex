defmodule JeopardyWeb.Components.Trebek.ReadingAnswer do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.GameServer

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[1fr_auto] h-[100dvh]">
      <.clue><%= @game.clue.answer %></.clue>
      <div class="p-4 grid">
        <.button class="btn-primary" phx-click="finished-reading" phx-target={@myself}>
          Continue
        </.button>
      </div>
    </div>
    """
  end

  def handle_event("finished-reading", _params, socket) do
    GameServer.action(socket.assigns.code, :finished_reading)
    {:noreply, socket}
  end
end
