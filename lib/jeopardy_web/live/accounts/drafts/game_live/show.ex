defmodule JeopardyWeb.Accounts.Drafts.GameLive.Show do
  use JeopardyWeb, :live_view

  alias Jeopardy.Drafts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:game, Drafts.get_game!(id))}
  end

  defp page_title(:show), do: "Show Game"
  defp page_title(:edit), do: "Edit Game"
end
