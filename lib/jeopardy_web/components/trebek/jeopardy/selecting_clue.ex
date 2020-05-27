defmodule JeopardyWeb.Components.Trebek.Jeopardy.SelectingClue do
  use JeopardyWeb, :live_component
  require Logger
  alias Jeopardy.GameState
  alias Jeopardy.Games.{Game, Clue}
  alias Jeopardy.Repo
  import Ecto.Query

  @impl true
  def render(assigns), do: JeopardyWeb.TrebekView.render(tpl_path(assigns), assigns)

  @impl true
  def update(assigns, socket),
    do: {:ok, assign(socket, assigns) |> assign(selected_category: nil)}

  @impl true
  def handle_event("select_category", %{"category" => category_name}, socket),
    do: {:noreply, assign(socket, selected_category: category_name)}

  @impl true
  def handle_event("select_clue", %{"clue_id" => clue_id}, socket) do
    game = socket.assigns.game
    set_current_clue(game, clue_id)
    clue = set_clue_to_asked(clue_id)

    case Clue.is_daily_double(clue) do
      true -> daily_double(game)
      _ -> normal(game)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("back", _params, socket),
    do: {:noreply, assign(socket, selected_category: nil)}

  defp set_current_clue(game, clue_id),
    do: Game.changeset(game, %{current_clue_id: clue_id}) |> Repo.update()

  defp set_clue_to_asked(clue_id) do
    {1, [clue | _]} =
      from(c in Clue, select: c, where: c.id == ^clue_id)
      |> Repo.update_all_ts(set: [asked_status: "asked"])

    clue
  end

  defp daily_double(game) do
    q =
      from g in Game,
        where: g.id == ^game.id,
        where: g.round_status == "selecting_clue"

    updates = [round_status: "awaiting_daily_double_wager", buzzer_player: game.board_control]
    Repo.update_all_ts(q, set: updates)

    Phoenix.PubSub.broadcast(
      Jeopardy.PubSub,
      game.code,
      {:round_status_change, "awaiting_daily_double_wager"}
    )
  end

  defp normal(game) do
    GameState.update_round_status(
      game.code,
      "selecting_clue",
      "reading_clue"
    )
  end
end
