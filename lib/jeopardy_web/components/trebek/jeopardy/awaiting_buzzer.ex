defmodule JeopardyWeb.Components.Trebek.Jeopardy.AwaitingBuzzer do
  use JeopardyWeb, :live_component
  require Logger
  alias Jeopardy.Games.Game
  alias Jeopardy.Repo
  import Ecto.Query

  @impl true
  def render(assigns), do: JeopardyWeb.TrebekView.render(tpl_path(assigns), assigns)
end
