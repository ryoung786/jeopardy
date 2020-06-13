defmodule JeopardyWeb.Components.Trebek.FinalJeopardy.RevealingCategory do
  use JeopardyWeb.Components.Base, :trebek
  alias Jeopardy.Games.{Game, Player}
  alias Jeopardy.Repo
  import Ecto.Query
  require Logger

  # @impl true
  # def mount(socket) do
  # end

  @impl true
  def handle_event("read_clue", _params, socket) do
    game = socket.assigns.game

    if all_final_jeopardy_wagers_submitted?(game) do
      # start clue timer
      Jeopardy.GameState.update_round_status(game.code, "revealing_category", "reading_clue")
    end

    {:noreply, socket}
  end

  @impl true
  def update(%{event: :final_jeopardy_wager, player: player}, socket) do
    game = socket.assigns.game

    {:ok,
     assign(socket,
       all_submitted?: all_final_jeopardy_wagers_submitted?(game),
       players_submitted: [player.name | socket.assigns.players_submitted]
     )}
  end

  @impl true
  def update(assigns, socket) do
    game = assigns.game

    socket =
      assign(socket, assigns)
      |> assign(
        all_submitted?: all_final_jeopardy_wagers_submitted?(game),
        players_submitted: players_submitted(game)
      )

    {:ok, socket}
  end

  defp all_final_jeopardy_wagers_submitted?(%Game{} = game) do
    num_yet_to_submit =
      from(p in Player,
        select: count(1),
        where: p.game_id == ^game.id,
        where: p.name != ^game.trebek,
        where: is_nil(p.final_jeopardy_wager)
      )
      |> Repo.one()

    num_yet_to_submit == 0
  end

  defp players_submitted(%Game{} = game) do
    from(p in Player,
      select: p.name,
      where: p.game_id == ^game.id,
      where: p.name != ^game.trebek,
      where: not is_nil(p.final_jeopardy_wager)
    )
    |> Repo.all()
  end
end
