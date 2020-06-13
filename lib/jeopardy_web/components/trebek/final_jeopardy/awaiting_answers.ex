defmodule JeopardyWeb.Components.Trebek.FinalJeopardy.AwaitingAnswers do
  use JeopardyWeb.Components.Base, :trebek
  require Logger

  @impl true
  def update(%{event: :final_jeopardy_answer_submitted, player_that_submitted: player}, socket) do
    statuses =
      Enum.map(socket.assigns.player_submit_status, fn p ->
        if p.name == player.name, do: %{name: p.name, submitted: true}, else: p
      end)

    next_round_if_all_players_submitted(statuses, socket.assigns.game.code)
    {:ok, assign(socket, player_submit_status: statuses)}
  end

  @impl true
  def update(assigns, socket) do
    statuses = player_submit_status(assigns.players)
    next_round_if_all_players_submitted(statuses, assigns.game.code)

    socket =
      assign(socket, assigns)
      |> assign(player_submit_status: statuses)

    startQuestionTimer(socket.assigns.game.code)
    {:ok, socket}
  end

  defp player_submit_status(players) do
    Enum.map(players, fn p ->
      %{
        name: p.name,
        submitted: not is_nil(p.final_jeopardy_answer) and p.final_jeopardy_answer != ""
      }
    end)
  end

  defp next_round_if_all_players_submitted(statuses, code) do
    if Enum.count(statuses, fn s -> not s.submitted end) == 0 do
      Task.start(fn ->
        # gives time to draw checkmarks and give visual feedback
        Process.sleep(1200)
        next_round(code)
      end)
    end
  end

  defp next_round(code) do
    Jeopardy.GameState.update_round_status(
      code,
      "awaiting_answers",
      "grading_answers"
    )
  end

  defp startQuestionTimer(code) do
    # 60.5 second timer (.5s is for leniency)
    Task.start(fn ->
      Process.sleep(60500)
      next_round(code)
    end)
  end
end
