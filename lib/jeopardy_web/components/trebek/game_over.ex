defmodule JeopardyWeb.Components.Trebek.GameOver do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.GameServer

  # def assign_init(socket, game) do
  #   contestant =
  #     assign(socket, revealed: game.fsm.revealed, contestant_name: contestant.name, contestant_state: :name)
  # end

  def render(assigns) do
    ~H"""
    <div>
      <.button class="btn btn-primary" phx-target={@myself} phx-click="play-again">
        Play Again
      </.button>
    </div>
    """
  end

  def handle_event("play-again", _params, socket) do
    GameServer.action(socket.assigns.code, :play_again)
    {:noreply, socket}
  end
end
