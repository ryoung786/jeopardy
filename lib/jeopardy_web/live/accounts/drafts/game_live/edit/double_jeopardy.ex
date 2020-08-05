defmodule JeopardyWeb.Accounts.Drafts.GameLive.Edit.DoubleJeopardy do
  use JeopardyWeb, :live_view
  alias Jeopardy.Drafts
  require Logger

  @impl true
  def handle_params(%{"id" => id}, _url, socket),
    do: {:noreply, assign(socket, game: Drafts.get_game!(id))}
end
