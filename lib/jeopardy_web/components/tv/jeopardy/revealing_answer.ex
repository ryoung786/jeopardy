defmodule JeopardyWeb.Components.TV.Jeopardy.RevealingAnswer do
  use JeopardyWeb, :live_component

  @impl true
  def render(assigns), do: JeopardyWeb.TvView.render(tpl_path(assigns), assigns)
end
