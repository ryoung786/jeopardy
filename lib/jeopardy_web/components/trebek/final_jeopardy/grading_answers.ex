defmodule JeopardyWeb.Components.Trebek.FinalJeopardy.GradingAnswers do
  use JeopardyWeb.Components.Base, :trebek
  require Logger
  import Ecto.Query, warn: false
  alias Jeopardy.Games

  @impl true
  def handle_event("submit", params, socket) do
    game = socket.assigns.game

    grades =
      params["grades"]
      |> Enum.map(fn {id, correct?} ->
        {String.to_integer(id), correct? == "true"}
      end)
      |> Enum.into(%{})

    store(game, socket.assigns.players, grades)
    Jeopardy.GameState.update_round_status(game.code, "grading_answers", "revealing_final_scores")

    {:noreply, socket}
  end

  def store(game, contestants, grades) do
    Enum.each(contestants, fn c ->
      if grades[c.id],
        do: Games.final_jeopardy_correct_answer(game, c),
        else: Games.final_jeopardy_incorrect_answer(game, c)
    end)
  end
end
