defmodule JeopardyWeb.Components.Trebek.RevealingBoard do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer

  def assign_init(socket, game) do
    assign(socket,
      categories: game.board.categories,
      index: game.fsm.data.revealed_category_count - 1
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <ul class="bg-blue-700">
        <li
          :for={{category, i} <- Enum.with_index(@categories)}
          class={i == @index && "bg-emerald-400"}
        >
          <%= category %>
        </li>
      </ul>
      <button
        :if={@index < Enum.count(@categories)}
        class="btn btn-primary"
        phx-click="next-category"
        phx-target={@myself}
      >
        <%= if @index < Enum.count(@categories), do: "Next Category", else: "Continue" %>
      </button>
    </div>
    """
  end

  def handle_game_server_msg({:revealed_category, index}, socket) do
    {:ok, assign(socket, index: index)}
  end

  def handle_event("next-category", _params, socket) do
    GameServer.action(socket.assigns.code, :reveal_next_category)
    {:noreply, assign(socket, index: socket.assigns.index + 1)}
  end
end
