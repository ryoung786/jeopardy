defmodule JeopardyWeb.Components.Contestant.GradingFinalJeopardyAnswers do
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
      <.trebek_clue category={"$#{@wager}"} clue={@answer} />
      <div class="p-4 bg-sky-100">
        <p class="p-4 shadow-lg bg-white rounded-lg text-center">
          Your answer is locked in.<br />
          Please wait while <%= @game.trebek %> checks all the submitted answers.
        </p>
      </div>
    </div>
    """
  end
end
