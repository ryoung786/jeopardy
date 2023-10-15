defmodule JeopardyWeb.Components.Trebek.AwaitingAnswer do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[1fr_auto_auto] min-h-screen">
      <.trebek_clue clue={@game.clue.answer} />
      <div class="text-center p-4">
        <%= @game.buzzer %> buzzed in.
      </div>
      <div class="grid grid-cols-2 px-4 pb-4 gap-4">
        <button class="btn btn-error" phx-click="incorrect" phx-target={@myself}>
          Incorrect
        </button>
        <button class="btn btn-primary" phx-click="correct" phx-target={@myself}>
          Correct
        </button>
      </div>
    </div>
    """
  end

  def handle_event("correct", _params, socket) do
    GameServer.action(socket.assigns.game.code, :answered, :correct)
    {:noreply, socket}
  end

  def handle_event("incorrect", _params, socket) do
    GameServer.action(socket.assigns.game.code, :answered, :incorrect)
    {:noreply, socket}
  end
end
