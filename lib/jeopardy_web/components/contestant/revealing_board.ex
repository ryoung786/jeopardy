defmodule JeopardyWeb.Components.Contestant.RevealingBoard do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    assign(socket,
      categories: game.board.categories,
      index: game.fsm.data.revealed_category_count - 1
    )
  end

  def render(assigns) do
    ~H"""
    <ul class="bg-blue-700">
      <li :for={{category, i} <- Enum.with_index(@categories)} class={i == @index && "bg-emerald-400"}>
        <%= category %>
      </li>
    </ul>
    """
  end

  def handle_game_server_msg({:revealed_category, index}, socket) do
    {:ok, assign(socket, index: index)}
  end
end
