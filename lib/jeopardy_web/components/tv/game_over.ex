defmodule JeopardyWeb.Components.Tv.GameOver do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.clue><span>Game Over</span></.clue>
      </.tv>
    </div>
    """
  end
end
