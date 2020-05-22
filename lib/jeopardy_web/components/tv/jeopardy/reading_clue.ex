defmodule JeopardyWeb.Components.TV.Jeopardy.ReadingClue do
  use JeopardyWeb, :live_component
  require Logger

  @impl true
  def render(assigns), do: JeopardyWeb.TvView.render(tpl_path(assigns), assigns)
end
