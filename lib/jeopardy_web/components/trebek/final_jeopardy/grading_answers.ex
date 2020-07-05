defmodule JeopardyWeb.Components.Trebek.FinalJeopardy.GradingAnswers do
  use JeopardyWeb.Components.Base, :trebek

  @impl true
  def handle_event("submit", params, socket) do
    grades =
      params["grades"]
      |> Enum.map(fn {id, correct?} ->
        {String.to_integer(id), correct? == "true"}
      end)
      |> Enum.into(%{})

    Engine.event(:trebek_submit_grades, grades, socket.assigns.game.id)

    {:noreply, socket}
  end
end
