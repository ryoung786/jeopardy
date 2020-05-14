defmodule JeopardyWeb.ScoreboardComponent do
  use JeopardyWeb, :live_component
  alias JeopardyWeb.ScoreboardView
  require Logger

  def render(assigns) do
    ScoreboardView.render("index.html", assigns)
  end

  def update(assigns, socket), do: {:ok, assign(socket, assigns)}
end
