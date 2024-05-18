defmodule JeopardyWeb.Components.Tv.AwaitingFinalJeopardyWagers do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.PlayerRemoved
  alias Jeopardy.Timers

  def assign_init(socket, game) do
    assign(socket, time_remaining: Timers.time_remaining(game.fsm.data[:expires_at]))
  end

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.clue><%= @game.clue.category %></.clue>
        <div
          class="w-8 h-8 opacity-50 absolute bottom-4"
          style="transform: translateX(calc(50vw - 50%))"
        >
          <.pie_timer time_remaining={@time_remaining} />
        </div>
      </.tv>
    </div>
    """
  end

  def handle_game_server_msg(%PlayerRemoved{name: name}, socket), do: handle_tv_player_removed(name, socket)
  def handle_game_server_msg(_, socket), do: {:ok, socket}
end
