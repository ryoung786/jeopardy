defmodule JeopardyWeb.Accounts.Drafts.GameLive.Edit.Jeopardy do
  use JeopardyWeb, :live_view
  alias Jeopardy.Drafts
  require Logger

  @impl true
  def handle_params(%{"id" => id, "clue_id" => clue_id, "round" => round}, _url, socket) do
    round = String.replace(round, "-", "_")
    game = Drafts.get_game!(id)
    clue = Drafts.get_clue!(game, clue_id)

    {:noreply,
     socket
     |> assign(round: round)
     |> assign(game: game)
     |> assign(clue: Drafts.get_clue!(game, clue_id))}
  end

  @impl true
  def handle_params(%{"id" => id, "round" => round}, _url, socket),
    do:
      {:noreply,
       socket
       |> assign(round: String.replace(round, "-", "_"))
       |> assign(game: Drafts.get_game!(id))}

  defp edit_path(socket, round, game) do
    round = String.replace(round, "_", "-")
    Routes.game_edit_jeopardy_path(socket, :edit, game, round)
  end
end
