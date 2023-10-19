defmodule JeopardyWeb.Components.Trebek.GameOver do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.GameServer

  def assign_init(socket, game) do
    assign(socket,
      contestants: game.fsm.data.contestants,
      index: game.fsm.data.index,
      contestant: Enum.at(game.fsm.data.contestants, game.fsm.data.index),
      steps_revealed: []
    )
  end

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[1fr_auto] min-h-screen">
      <.trebek_clue>
        <div :if={@contestant}>
          <.reveal_text show={:name in @steps_revealed}>
            <%= @contestant.name %>
          </.reveal_text>
          <.reveal_text show={:wager in @steps_revealed}>
            <%= @contestant.final_jeopardy_wager %>
          </.reveal_text>
          <.reveal_text show={:answer in @steps_revealed}>
            <%= @contestant.final_jeopardy_answer || "No answer" %>
          </.reveal_text>
        </div>

        <span :if={!@contestant}>Game Over</span>
      </.trebek_clue>
      <div class="p-4 grid">
        <.button :if={@contestant} class="btn-primary" phx-click="next" phx-target={@myself}>
          Next
        </.button>
        <.button
          :if={@contestant == nil}
          class="btn btn-primary"
          phx-target={@myself}
          phx-click="play-again"
        >
          Play Again
        </.button>
      </div>
    </div>
    """
  end

  defp reveal_text(assigns) do
    ~H"""
    <h1 class={[
      "transition-all transform ease-out duration-300",
      not @show && "opacity-0 -translate-y-4 scale-95",
      @show && "opacity-100 translate-y-0 scale-100"
    ]}>
      <%= render_slot(@inner_block) %>
    </h1>
    """
  end

  def handle_event("next", _params, socket) do
    revealed =
      case socket.assigns.steps_revealed do
        [] -> [:name]
        [:name | _] -> [:wager | socket.assigns.steps_revealed]
        [:wager | _] -> [:answer | socket.assigns.steps_revealed]
        [:answer | _] -> []
      end

    socket =
      if revealed == [] do
        GameServer.action(socket.assigns.code, :revealed_contestant)
        index = socket.assigns.index + 1
        assign(socket, index: index, contestant: Enum.at(socket.assigns.contestants, index), steps_revealed: [:name])
      else
        assign(socket, steps_revealed: revealed)
      end

    {:noreply, socket}
  end

  def handle_event("play-again", _params, socket) do
    GameServer.action(socket.assigns.code, :play_again)
    {:noreply, socket}
  end
end
