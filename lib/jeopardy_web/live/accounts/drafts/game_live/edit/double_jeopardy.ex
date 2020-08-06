defmodule JeopardyWeb.Accounts.Drafts.GameLive.Edit.DoubleJeopardy do
  use JeopardyWeb, :live_view
  alias Jeopardy.Drafts
  require Logger

  @impl true
  def handle_params(%{"id" => id, "clue_id" => clue_id}, _url, socket) do
    game = Drafts.get_game!(id)
    clue = Drafts.get_clue!(game, clue_id)

    {:noreply,
     socket
     |> assign(game: game)
     |> assign(clue: Drafts.get_clue!(game, clue_id))}
  end

  @impl true
  def handle_params(%{"id" => id}, _url, socket),
    do: {:noreply, assign(socket, game: Drafts.get_game!(id))}
end
