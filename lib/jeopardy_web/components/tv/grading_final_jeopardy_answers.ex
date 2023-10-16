defmodule JeopardyWeb.Components.Tv.GradingFinalJeopardyAnswers do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.clue category={@game.clue.category} clue={@game.clue.clue} />
      </.tv>
    </div>
    """
  end
end
