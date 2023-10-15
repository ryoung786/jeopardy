defmodule JeopardyWeb.Components.Tv.RecappingRound do
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.clue clue="Round complete" />
      </.tv>
    </div>
    """
  end
end
