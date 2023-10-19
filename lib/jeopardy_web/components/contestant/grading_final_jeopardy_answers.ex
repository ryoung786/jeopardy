defmodule JeopardyWeb.Components.Contestant.GradingFinalJeopardyAnswers do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    contestant = game.contestants[socket.assigns.name]

    assign(socket,
      answer: contestant.final_jeopardy_answer,
      wager: contestant.final_jeopardy_wager
    )
  end

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[1fr_auto] min-h-screen">
      <.trebek_clue category={"$#{@wager}"}><%= @answer || "No answer" %></.trebek_clue>
      <.instructions full_width?={true}>
        Your answer is locked in.<br />
        Please wait while <%= @game.trebek %> checks all the submitted answers.
      </.instructions>
    </div>
    """
  end
end
