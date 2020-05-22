defmodule JeopardyWeb.Components.TV.Jeopardy.RevealingBoard do
  use JeopardyWeb, :live_component
  require Logger

  @impl true
  def mount(socket), do: {:ok, assign(socket, active_category_num: 0)}

  @impl true
  def render(assigns), do: JeopardyWeb.TvView.render(tpl_path(assigns), assigns)

  # @impl true
  # def update(assigns, socket) do

  #   socket =
  #     socket
  #     |> assign(assigns)

  #   {:ok, socket}
  # end
end
