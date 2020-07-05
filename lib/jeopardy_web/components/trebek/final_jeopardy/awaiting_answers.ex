defmodule JeopardyWeb.Components.Trebek.FinalJeopardy.AwaitingAnswers do
  use JeopardyWeb.Components.Base, :trebek
  require Logger

  @impl true
  def update(assigns, socket) do
    statuses = player_submit_status(assigns.players)

    socket =
      assign(socket, assigns)
      |> assign(player_submit_status: statuses)

    {:ok, socket}
  end

  defp player_submit_status(players) do
    Enum.map(Map.values(players), fn p ->
      %{
        name: p.name,
        submitted: not is_nil(p.final_jeopardy_answer) and p.final_jeopardy_answer != ""
      }
    end)
  end
end
