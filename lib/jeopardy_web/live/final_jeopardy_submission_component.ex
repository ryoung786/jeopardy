defmodule JeopardyWeb.FinalJeopardySubmissionComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML
  require Logger

  def render(assigns) do
    JeopardyWeb.FinalJeopardySubmissionView.render(
      "final_jeopardy_submission.html",
      assigns
    )
  end

  def handle_event("save", %{"submission" => %{"answer" => answer}}, socket) do
    Jeopardy.GameEngine.event(
      :answer_submitted,
      %{
        player_id: socket.assigns.player.id,
        answer: answer
      },
      socket.assigns.game.id
    )

    {:noreply, socket}
  end
end
