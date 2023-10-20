defmodule JeopardyWeb.Components.Contestant.ReadingAnswer do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div class="h-screen">
      <.clue><%= @game.clue.answer %></.clue>
    </div>
    """
  end
end
