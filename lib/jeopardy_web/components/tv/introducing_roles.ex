defmodule JeopardyWeb.Components.Tv.IntroducingRoles do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    assign(socket, trebek: game.trebek)
  end

  def render(assigns) do
    ~H"""
    <h1>Host: <%= @trebek %></h1>
    """
  end
end
