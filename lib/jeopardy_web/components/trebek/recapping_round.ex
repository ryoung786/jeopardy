defmodule JeopardyWeb.Components.Trebek.RecappingRound do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer

  def assign_init(socket, game) do
    assign(socket, round: game.round)
  end

  def render(assigns) do
    ~H"""
    <div class="bg-sky-100 min-h-screen p-4 grid place-items-center">
      <p class="shadow-lg p-4 bg-white rounded-lg text-center">
        <%= if @round == :jeopardy do %>
          That's the end of the Jeopardy round!<br /> When you're ready, continue to the next round.
        <% else %>
          That's the end of the Double Jeopardy round!<br />
          When you're ready, continue to Final Jeopardy.
        <% end %>
      </p>
      <.button class="btn btn-primary" phx-click="continue" phx-target={@myself}>
        Continue
      </.button>
    </div>
    """
  end

  def handle_event("continue", _params, socket) do
    GameServer.action(socket.assigns.code, :next_round)
    {:noreply, socket}
  end
end
