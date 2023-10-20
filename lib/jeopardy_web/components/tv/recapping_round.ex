defmodule JeopardyWeb.Components.Tv.RecappingRound do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.clue>Round complete</.clue>
      </.tv>
    </div>
    """
  end
end
