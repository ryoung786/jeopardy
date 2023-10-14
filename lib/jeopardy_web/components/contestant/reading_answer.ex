defmodule JeopardyWeb.Components.Contestant.ReadingAnswer do
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <p><%= @game.clue.answer %></p>
    """
  end
end
