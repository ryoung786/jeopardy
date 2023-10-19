defmodule JeopardyWeb.Components.Tv.IntroducingRoles do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    assign(socket, trebek: game.trebek)
  end

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.clue clue={"Host: #{@trebek}"} />
      </.tv>
    </div>
    """
  end
end
