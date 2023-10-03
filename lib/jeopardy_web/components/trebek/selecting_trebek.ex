defmodule JeopardyWeb.Components.Trebek.SelectingTrebek do
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <p>Congratulations, you'll be hosting this round of Jeopardy!</p>
    </div>
    """
  end
end
