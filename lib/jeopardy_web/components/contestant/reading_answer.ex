defmodule JeopardyWeb.Components.Contestant.ReadingAnswer do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div class="h-screen">
      <.clue clue={@game.clue.answer} />
    </div>
    """
  end
end
