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
    changeset = Player.changeset(socket.assigns.player, %{final_jeopardy_answer: answer})

    with {:ok, player} <- Repo.update(changeset) do
      Phoenix.PubSub.broadcast(Jeopardy.PubSub, socket.assigns.game.code, %{
        event: :final_jeopardy_answer_submitted,
        player_that_submitted: player
      })

      {:noreply, assign(socket, player: player)}
    else
      _ -> {:noreply, socket}
    end
  end
end
