defmodule JeopardyWeb.Components.Trebek.ReadingDailyDoubleClue do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.GameServer

  def assign_init(socket, _game) do
    assign(socket, finished_reading: false)
  end

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[1fr_auto] min-h-screen">
      <%= if @finished_reading do %>
        <.trebek_clue><%= @game.clue.answer %></.trebek_clue>
        <div class="grid grid-cols-2 p-4 gap-4">
          <button class="btn btn-error" phx-click="incorrect" phx-target={@myself}>
            Incorrect
          </button>
          <button class="btn btn-success" phx-click="correct" phx-target={@myself}>
            Correct
          </button>
        </div>
      <% else %>
        <.trebek_clue category={@game.clue.category}><%= @game.clue.clue %></.trebek_clue>
        <div class="p-4 grid">
          <.button class="btn-primary" phx-click="finished-reading" phx-target={@myself}>
            Finished Reading
          </.button>
        </div>
      <% end %>
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

  def handle_event("finished-reading", _params, socket) do
    {:noreply, assign(socket, finished_reading: true)}
  end
end
