defmodule JeopardyWeb.Components.Tv.ReadingAnswer do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    assign(socket, answer: game.clue.answer)
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3><%= @answer %></h3>
    </div>
    """
  end
end
