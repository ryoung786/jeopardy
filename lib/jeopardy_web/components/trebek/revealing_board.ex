defmodule JeopardyWeb.Components.Trebek.RevealingBoard do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.RevealedCategory
  alias Jeopardy.GameServer

  def assign_init(socket, game) do
    assign(socket,
      categories: game.board.categories,
      index: game.fsm.data.revealed_category_count - 1
    )
  end

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[1fr_auto] h-[100dvh]">
      <div class="w-screen overflow-clip">
        <ul
          class="h-full grid transition-transform duration-1000"
          style={[
            "grid-template-columns: repeat(#{Enum.count(@categories) + 1}, 100%);",
            "transform: translateX(calc(-100vw * #{@index + 1}))"
          ]}
        >
          <li class="bg-blue-800 w-full h-full"></li>
          <li :for={category <- @categories} class="xp-4">
            <.trebek_clue><%= category %></.trebek_clue>
          </li>
        </ul>
      </div>
      <div class="p-4 grid">
        <.button
          :if={@index < Enum.count(@categories)}
          class="btn-primary"
          phx-click="next-category"
          phx-target={@myself}
        >
          <%= if @index < Enum.count(@categories) - 1, do: "Next Category", else: "Continue" %>
        </.button>
      </div>
    </div>
    """
  end

  def handle_game_server_msg(%RevealedCategory{index: index}, socket) do
    {:ok, assign(socket, index: index)}
  end

  def handle_event("next-category", _params, socket) do
    GameServer.action(socket.assigns.code, :reveal_next_category)
    {:noreply, assign(socket, index: socket.assigns.index + 1)}
  end
end
