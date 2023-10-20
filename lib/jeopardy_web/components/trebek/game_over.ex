defmodule JeopardyWeb.Components.Trebek.GameOver do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.FinalScoresRevealed
  alias Jeopardy.FSM.Messages.ScoreUpdated
  alias Jeopardy.GameServer

  def assign_init(socket, game) do
    socket = assign(socket, name: nil, wager: nil, answer: nil, game_over?: game.fsm.data.state == :game_over)

    c = Enum.at(game.fsm.data.contestants, game.fsm.data.index)

    case game.fsm.data.state do
      :answer -> assign(socket, name: c.name, wager: c.final_jeopardy_wager, answer: c.final_jeopardy_answer)
      :wager -> assign(socket, name: c.name, wager: c.final_jeopardy_wager)
      :name -> assign(socket, name: c.name)
      _ -> socket
    end
  end

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[1fr_auto] min-h-screen">
      <.trebek_clue>
        <div :if={!@game_over?}>
          <.reveal_text show={@name}><%= @name %></.reveal_text>
          <.reveal_text show={@wager}><%= @wager %></.reveal_text>
          <.reveal_text show={@answer}><%= @answer %></.reveal_text>
        </div>

        <span :if={@game_over?}>Game Over</span>
      </.trebek_clue>
      <div class="p-4 grid">
        <.button :if={!@game_over?} class="btn-primary" phx-click="next" phx-target={@myself}>
          Next
        </.button>
        <.button :if={@game_over?} class="btn btn-primary" phx-target={@myself} phx-click="play-again">
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
      !@show && "opacity-0 -translate-y-4 scale-95",
      @show && "opacity-100 translate-y-0 scale-100"
    ]}>
      <%= render_slot(@inner_block) %>
    </h1>
    """
  end

  def handle_event("next", _params, socket) do
    GameServer.action(socket.assigns.code, :revealed)
    {:noreply, socket}
  end

  def handle_event("play-again", _params, socket) do
    GameServer.action(socket.assigns.code, :play_again)
    {:noreply, socket}
  end

  def handle_game_server_msg(%FinalScoresRevealed{state: state, value: value}, socket) do
    case state do
      nil -> {:ok, assign(socket, name: nil, wager: nil, answer: nil)}
      :name -> {:ok, assign(socket, name: value, wager: nil, answer: nil)}
      :wager -> {:ok, assign(socket, wager: value, answer: nil)}
      :answer -> {:ok, assign(socket, answer: value)}
      :game_over -> {:ok, assign(socket, name: nil, wager: nil, answer: nil, game_over?: true)}
    end
  end

  def handle_game_server_msg(%ScoreUpdated{}, socket) do
    {:ok, socket}
  end
end
