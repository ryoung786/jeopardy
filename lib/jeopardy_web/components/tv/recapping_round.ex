defmodule JeopardyWeb.Components.Tv.RecappingRound do
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <h3>Round complete</h3>
      </.tv>
    </div>
    """
  end
end
