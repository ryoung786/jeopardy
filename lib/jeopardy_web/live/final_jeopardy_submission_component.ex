defmodule JeopardyWeb.FinalJeopardySubmissionComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML
  alias JeopardyWeb.FinalJeopardySubmissionView
  alias Jeopardy.Games.Player
  alias Jeopardy.Repo
  require Logger

  def render(assigns) do
    FinalJeopardySubmissionView.render("final_jeopardy_submission.html", assigns)
  end

  def handle_event("save", %{"submission" => %{"answer" => answer}}, socket) do
    {:ok, player} =
      Player.changeset(socket.assigns.player, %{final_jeopardy_answer: answer})
      |> Repo.update()
    {:noreply, assign(socket, player: player)}
  end
end
