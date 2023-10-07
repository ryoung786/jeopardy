defmodule JeopardyWeb.Components.Contestant.GradingFinalJeopardyAnswers do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    contestant = game.contestants[socket.assigns.name]

    assign(socket, answer: contestant.final_jeopardy_answer)
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3><%= @answer %></h3>
      <p>Your answer is locked in.</p>
      <p>Please wait while <%= @trebek %> checks all the submitted answers.</p>
    </div>
    """
  end
end
