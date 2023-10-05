defmodule JeopardyWeb.Components.Trebek.RecappingRound do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer

  def assign_init(socket, game) do
    assign(socket, round: game.round)
  end

  def render(assigns) do
    ~H"""
    <div>
      <div :if={@round == :jeopardy}>
        <p>That's the end of the Jeopardy round!</p>
        <p>When you're ready, continue to the next round.</p>
      </div>
      <div :if={@round == :double_jeopardy}>
        <p>That's the end of the Double Jeopardy round!</p>
        <p>When you're ready, continue to Final Jeopardy.</p>
      </div>

      <button class="btn btn-primary" phx-click="continue" phx-target={@myself}>
        Continue
      </button>
    </div>
    """
  end

  def handle_event("continue", _params, socket) do
    GameServer.action(socket.assigns.code, :continue)
    {:noreply, socket}
  end
end
