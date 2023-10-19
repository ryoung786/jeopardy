defmodule JeopardyWeb.Components.Tv.GameOver do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.FinalScoresRevealed
  alias Jeopardy.FSM.Messages.ScoreUpdated

  def assign_init(socket, game) do
    assign(socket,
      category: game.clue.category,
      clue: game.clue.clue
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.clue clue="Game Over" />
      </.tv>
    </div>
    """
  end

  def handle_game_server_msg(%ScoreUpdated{} = msg, socket) do
    {:ok, put_in(socket.assigns.game.contestants[msg.contestant_name].score, msg.to)}
  end

  def handle_game_server_msg(%FinalScoresRevealed{}, socket) do
    {:ok, socket}
  end
end
