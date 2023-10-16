defmodule JeopardyWeb.Components.Trebek.RecappingRound do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.GameServer

  def assign_init(socket, game) do
    assign(socket, round: game.round)
  end

  def render(assigns) do
    ~H"""
    <div class="bg-sky-100 min-h-screen grid grid-rows-[1fr_auto]">
      <.instructions>
        <%= if @round == :jeopardy do %>
          That's the end of the Jeopardy round!<br /> When you're ready, continue to the next round.
        <% else %>
          That's the end of the Double Jeopardy round!<br />
          When you're ready, continue to Final Jeopardy.
        <% end %>
      </.instructions>
      <div class="bg-white p-4 grid">
        <.button class="btn btn-primary" phx-click="continue" phx-target={@myself}>
          Continue
        </.button>
      </div>
    </div>
    """
  end

  def handle_event("continue", _params, socket) do
    GameServer.action(socket.assigns.code, :next_round)
    {:noreply, socket}
  end
end
