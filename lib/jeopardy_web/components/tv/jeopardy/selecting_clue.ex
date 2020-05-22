defmodule JeopardyWeb.Components.TV.Jeopardy.SelectingClue do
  use JeopardyWeb, :live_component
  require Logger

  @impl true
  def render(assigns), do: JeopardyWeb.TvView.render(tpl_path(assigns), assigns)
end
