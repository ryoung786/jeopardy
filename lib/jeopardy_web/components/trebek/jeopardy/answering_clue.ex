defmodule JeopardyWeb.Components.Trebek.Jeopardy.AnsweringClue do
  use JeopardyWeb.Components.Base, :trebek
  alias Jeopardy.Games
  alias Jeopardy.GameState

  @impl true
  def handle_event("correct", _params, socket) do
    {:ok, game} =
      Games.correct_answer(socket.assigns.game)
      |> Games.lock_buzzer()
      |> Games.assign_board_control(socket.assigns.game.buzzer_player)

    GameState.to_selecting_clue(game)
    {:noreply, socket}
  end

  @impl true
  def handle_event("incorrect", _params, socket) do
    Games.incorrect_answer(socket.assigns.game)
    {:noreply, socket}
  end
end
