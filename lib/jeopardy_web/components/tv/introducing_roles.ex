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
        <.clue><%= "Host: #{@trebek}" %></.clue>
      </.tv>
    </div>
    """
  end
end
