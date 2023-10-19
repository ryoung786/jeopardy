defmodule JeopardyWeb.Components.Contestant.GameOver do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.GameServer

  def assign_init(socket, game) do
    contestants = game.fsm.data.contestants
    index = game.fsm.data.index

    assign(socket,
      current_name: nil,
      wager: nil,
      answer: nil,
      show_play_again?: index >= Enum.count(contestants)
    )
  end

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[1fr_auto] min-h-screen">
      <.trebek_clue>
        <span :if={!@current_name}>Game Over</span>
      </.trebek_clue>
      <.instructions :if={not @show_play_again?} full_width?={true}>
        Final Jeopardy
      </.instructions>
      <div :if={@show_play_again?} class="p-4 grid">
        <.button class="btn btn-primary" phx-target={@myself} phx-click="play-again">
          Play Again
        </.button>
      </div>
    </div>
    """
  end

  def handle_event("play-again", _params, socket) do
    GameServer.action(socket.assigns.code, :play_again)
    {:noreply, socket}
  end
end
