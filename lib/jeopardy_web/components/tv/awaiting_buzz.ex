defmodule JeopardyWeb.Components.Tv.AwaitingBuzz do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.PlayerRemoved
  alias Jeopardy.Timers

  def assign_init(socket, game) do
    assign(socket,
      time_remaining: Timers.time_remaining(game.fsm.data[:expires_at])
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.clue category={@game.clue.category}><%= @game.clue.clue %></.clue>
        <:timer><.lights_timer timer_seconds={5} time_remaining={@time_remaining} /></:timer>
      </.tv>
    </div>
    """
  end

  def handle_game_server_msg(%PlayerRemoved{name: name}, socket), do: handle_tv_player_removed(name, socket)
  def handle_game_server_msg(_, socket), do: {:ok, socket}
end
