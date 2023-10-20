defmodule JeopardyWeb.Components.Tv.GameOver do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.FinalScoresRevealed
  alias Jeopardy.FSM.Messages.ScoreUpdated

  def assign_init(socket, game) do
    c = Enum.at(game.fsm.data.contestants, game.fsm.data.index)

    socket =
      assign(socket,
        contestant: c,
        show_name: false,
        show_wager: false,
        show_answer: false,
        game_over?: game.fsm.data.state == :game_over
      )

    case game.fsm.data.state do
      :answer -> assign(socket, show_name: true, show_wager: true, show_answer: true)
      :wager -> assign(socket, show_name: true, show_wager: true)
      :name -> assign(socket, show_name: true)
      _ -> socket
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <pre :if={assigns[:foo]}>what</pre>
      <.tv contestants={@game.contestants} buzzer={@show_name && @contestant.name}>
        <.clue>
          <div :if={!@game_over?}>
            <.reveal_text show={@show_name}><%= @contestant.name %></.reveal_text>
            <.reveal_text show={@show_wager}><%= @contestant.final_jeopardy_wager %></.reveal_text>
            <.reveal_text show={@show_answer}>
              <%= @contestant.final_jeopardy_answer || "No answer" %>
            </.reveal_text>
          </div>

          <span :if={@game_over?}>Game Over</span>
        </.clue>
      </.tv>
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
      nil -> {:ok, assign(socket, show_name: false, show_wager: false, show_answer: false)}
      :name -> {:ok, assign(socket, show_name: true, show_wager: false, show_answer: false)}
      :wager -> {:ok, assign(socket, show_wager: true, show_answer: false)}
      :answer -> {:ok, assign(socket, show_answer: true)}
      :game_over -> {:ok, assign(socket, show_name: false, show_wager: false, show_answer: false, game_over?: true)}
    end
  end
end
