defmodule JeopardyWeb.Components.Trebek.ReadingDailyDoubleClue do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer

  def assign_init(socket, game) do
    assign(socket, answer: game.clue.answer)
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3><%= @answer %></h3>
      <.button class="btn-error" phx-click="incorrect" phx-target={@myself}>
        Incorrect
      </.button>
      <.button class="btn-primary" phx-click="correct" phx-target={@myself}>
        Correct
      </.button>
    </div>
    """
  end

  def handle_event("correct", _params, socket) do
    GameServer.action(socket.assigns.code, :answered, :correct)
    {:noreply, socket}
  end

  def handle_event("incorrect", _params, socket) do
    GameServer.action(socket.assigns.code, :answered, :incorrect)
    {:noreply, socket}
  end
end
