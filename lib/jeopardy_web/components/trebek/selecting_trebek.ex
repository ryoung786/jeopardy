defmodule JeopardyWeb.Components.Trebek.SelectingTrebek do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div class="h-[100dvh]">
      <.instructions>
        Congratulations, you'll be hosting this round of Jeopardy!
      </.instructions>
    </div>
    """
  end
end
