defmodule JeopardyWeb.Components.Tv.RevealingCorrectFinalJeopardyAnswer do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.clue category={@game.clue.category}><%= @game.clue.answer %></.clue>
      </.tv>
    </div>
    """
  end
end
