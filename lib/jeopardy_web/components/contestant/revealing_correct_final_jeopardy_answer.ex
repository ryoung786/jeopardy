defmodule JeopardyWeb.Components.Contestant.RevealingCorrectFinalJeopardyAnswer do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div class="grid grid-rows-[1fr_auto] min-h-[100dvh]">
      <.trebek_clue><span>Game Over</span></.trebek_clue>
    </div>
    """
  end
end
