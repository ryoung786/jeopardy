defmodule JeopardyWeb.Components.TV.Jeopardy.RecappingScores do
  use JeopardyWeb.Components.Base, :tv

  @impl true
  def handle_event("toggle-stats", _params, socket) do
    {:noreply, assign(socket, show_stats: !socket.assigns.show_stats)}
  end

  @impl true
  def handle_event("dismiss-modal", _params, socket) do
    {:noreply, assign(socket, show_stats: false)}
  end

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns) |> assign(show_stats: false)
    {:ok, socket}
  end
end
