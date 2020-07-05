defmodule JeopardyWeb.Components.Trebek.FinalJeopardy.RevealingCategory do
  use JeopardyWeb.Components.Base, :trebek
  require Logger

  @impl true
  def handle_event("read_clue", _params, socket) do
    game = socket.assigns.game

    if all_final_jeopardy_wagers_submitted?(socket.assigns.player_submit_status) do
      Jeopardy.GameState.update_round_status(game.code, "revealing_category", "reading_clue")
    end

    {:noreply, socket}
  end

  @impl true
  def update(%{event: :final_jeopardy_wager, player_wagered: player}, socket) do
    statuses =
      Enum.map(socket.assigns.player_submit_status, fn p ->
        if p.name == player.name, do: %{name: p.name, submitted: true}, else: p
      end)

    {:ok,
     assign(socket,
       all_submitted?: all_final_jeopardy_wagers_submitted?(statuses),
       player_submit_status: statuses
     )}
  end

  @impl true
  def update(assigns, socket) do
    statuses =
      Enum.map(Map.values(assigns.players), fn p ->
        %{
          name: p.name,
          submitted: not is_nil(p.final_jeopardy_wager)
        }
      end)

    socket =
      assign(socket, assigns)
      |> assign(
        all_submitted?: all_final_jeopardy_wagers_submitted?(statuses),
        player_submit_status: statuses
      )

    {:ok, socket}
  end

  defp all_final_jeopardy_wagers_submitted?(statuses) do
    Enum.count(statuses, fn s -> not s.submitted end) == 0
  end
end
