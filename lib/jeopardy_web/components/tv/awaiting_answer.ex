defmodule JeopardyWeb.Components.Tv.AwaitingAnswer do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants} buzzer={@game.buzzer}>
        <.clue category={@game.clue.category} clue={@game.clue.clue} />
      </.tv>
    </div>
    """
  end
end
