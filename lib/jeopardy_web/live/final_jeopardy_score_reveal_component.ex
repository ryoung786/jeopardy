defmodule JeopardyWeb.FinalJeopardyScoreRevealComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML
  alias JeopardyWeb.FinalJeopardyScoreRevealView
  require Logger

  def render(assigns) do
    FinalJeopardyScoreRevealView.render("final_jeopardy_score_reveal.html", assigns)
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)

    socket =
      socket
      |> assign(player_id: socket.assigns[:player_id] || nil)
      |> assign(step: socket.assigns[:step] || nil)

    {:ok, socket}
  end
end
