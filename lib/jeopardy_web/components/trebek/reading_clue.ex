defmodule JeopardyWeb.Components.Trebek.ReadingClue do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.GameServer

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[1fr_auto] min-h-screen">
      <.trebek_clue category={@game.clue.category} clue={@game.clue.clue} />
      <div class="p-4 grid">
        <.button class="btn-primary" phx-click="continue" phx-target={@myself}>
          Finished Reading
        </.button>
      </div>
    </div>
    """
  end

  def handle_event("continue", _params, socket) do
    GameServer.action(socket.assigns.code, :finished_reading)
    {:noreply, socket}
  end
end
