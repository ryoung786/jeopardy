defmodule JeopardyWeb.Components.Tv.ReadingAnswer do
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.clue category={@game.clue.category} clue={@game.clue.answer} />
      </.tv>
    </div>
    """
  end
end
