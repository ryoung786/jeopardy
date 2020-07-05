defmodule JeopardyWeb.Components.Trebek.FinalJeopardy.RevealingCategory do
  use JeopardyWeb.Components.Base, :trebek
  require Logger

  @impl true
  def handle_event("read_clue", _params, socket) do
    Engine.event(:trebek_advance, socket.assigns.game.id)
    {:noreply, socket}
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

  defp all_final_jeopardy_wagers_submitted?(statuses),
    do: Enum.all?(statuses, fn s -> s.submitted end)
end
