defmodule JeopardyWeb.Components.Contestant.RevealingBoard do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.RevealedCategory

  def assign_init(socket, game) do
    assign(socket,
      categories: game.board.categories,
      index: game.fsm.data.revealed_category_count - 1
    )
  end

  def render(assigns) do
    ~H"""
    <div class="w-screen h-[100dvh] overflow-clip">
      <ul
        class={[
          "w-full h-full text-neutral-100 text-shadow font-serif grid",
          "transition-transform duration-1000"
        ]}
        style={[
          "grid-template-columns: repeat(#{Enum.count(@categories) + 1}, 100%);",
          "transform: translateX(calc(-100vw * #{@index + 1}))"
        ]}
      >
        <li class="bg-blue-800 w-full h-full"></li>
        <li
          :for={{category, i} <- Enum.with_index(@categories)}
          class={[
            "bg-blue-800 transition-transform w-full h-full grid place-items-center text-3xl",
            i != @index && "opacity-100 translate-x-fullx",
            i == @index && "opacity-100 translate-x-0x"
          ]}
        >
          <%= category %>
        </li>
      </ul>
    </div>
    """
  end

  def handle_game_server_msg(%RevealedCategory{index: index}, socket) do
    {:ok, assign(socket, index: index)}
  end
end
