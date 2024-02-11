defmodule JeopardyWeb.Components.Contestant.RevealingFinalJeopardyAnswers do
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
        show_answer: false
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
    <div class="grid grid-rows-[1fr_auto] min-h-[100dvh]">
      <.trebek_clue>
        <div>
          <.reveal_text show={@show_name}><%= @contestant.name %></.reveal_text>
          <.reveal_text show={@show_wager}><%= @contestant.final_jeopardy_wager %></.reveal_text>
          <.reveal_text show={@show_answer}>
            <%= @contestant.final_jeopardy_answer || "No answer" %>
          </.reveal_text>
        </div>
      </.trebek_clue>
      <div class="grid">
        <.instructions>Revealing Scores</.instructions>
      </div>
    </div>
    """
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
      :game_over -> {:ok, assign(socket, show_name: false, show_wager: false, show_answer: false)}
    end
  end

  def handle_game_server_msg(%ScoreUpdated{}, socket) do
    {:ok, socket}
  end
end
