defmodule JeopardyWeb.Components.Tv.GameOver do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.FinalScoresRevealed
  alias Jeopardy.FSM.Messages.ScoreUpdated

  def assign_init(socket, game) do
    c = Enum.at(game.fsm.data.contestants, game.fsm.data.index)

    socket =
      assign(socket, contestant: c, name: nil, wager: nil, answer: nil, game_over?: game.fsm.data.state == :game_over)

    case game.fsm.data.state do
      :answer -> assign(socket, name: c.name, wager: c.final_jeopardy_wager, answer: c.final_jeopardy_answer)
      :wager -> assign(socket, name: c.name, wager: c.final_jeopardy_wager)
      :name -> assign(socket, name: c.name)
      _ -> socket
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <pre :if={assigns[:foo]}>what</pre>
      <.tv contestants={@game.contestants} buzzer={@name}>
        <.clue>
          <div :if={!@game_over?}>
            <.reveal_text show={@name}><%= @contestant.name %></.reveal_text>
            <.reveal_text show={@wager}><%= @contestant.final_jeopardy_wager %></.reveal_text>
            <.reveal_text show={@answer}>
              <%= @contestant.final_jeopardy_answer || "No answer" %>
            </.reveal_text>
          </div>

          <span :if={@game_over?}>Game Over</span>
        </.clue>
      </.tv>
    </div>
    """
  end

  defp reveal_text(assigns) do
    ~H"""
    <div class={[
      "transition-all transform ease-out duration-300",
      !@show && "opacity-0 -translate-y-4 scale-95",
      @show && "opacity-100 translate-y-0 scale-100"
    ]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def handle_game_server_msg(%ScoreUpdated{} = msg, socket) do
    game = socket.assigns.game

    {:ok, assign(socket, game: put_in(game.contestants[msg.contestant_name].score, msg.to))}
  end

  def handle_game_server_msg(%FinalScoresRevealed{state: state, value: value}, socket) do
    socket =
      if state == :name,
        do: assign(socket, contestant: socket.assigns.game.contestants[value]),
        else: socket

    case state do
      nil -> {:ok, assign(socket, name: nil, wager: nil, answer: nil)}
      :name -> {:ok, assign(socket, name: value, wager: nil, answer: nil)}
      :wager -> {:ok, assign(socket, wager: value, answer: nil)}
      :answer -> {:ok, assign(socket, answer: value)}
      :game_over -> {:ok, assign(socket, name: nil, wager: nil, answer: nil, game_over?: true)}
    end
  end
end
