defmodule JeopardyWeb.Components.Contestant.ReadingAnswer do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    assign(socket, answer: game.clue.answer)
  end

  def render(assigns) do
    ~H"""
    <p><%= @answer %></p>
    """
  end
end
