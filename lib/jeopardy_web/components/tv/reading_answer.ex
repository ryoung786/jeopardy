defmodule JeopardyWeb.Components.Tv.ReadingAnswer do
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <h3><%= @game.clue.answer %></h3>
    </div>
    """
  end
end
