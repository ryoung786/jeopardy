defmodule JeopardyWeb.Components.Trebek.Jeopardy.RecappingScores do
  use JeopardyWeb.Components.Base, :trebek
  alias Jeopardy.GameState
  alias Jeopardy.Games.{Game, Clue, Player}
  alias Jeopardy.Repo
  import Ecto.Query
  require Logger

  @impl true
  def handle_event("advance_to_double_jeopardy", _params, socket) do
    game = socket.assigns.game

    case game.status do
      "jeopardy" ->
        GameState.update_game_status(game.code, "jeopardy", "double_jeopardy", "revealing_board")

      "double_jeopardy" ->
        set_final_jeopardy_clue(game)
        zero_out_negative_scores(game)
        # TODO start wager timer
        GameState.update_game_status(
          game.code,
          "double_jeopardy",
          "final_jeopardy",
          "revealing_category"
        )
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event(e, params, socket) do
    Logger.info("e: #{inspect(e)}")
    Logger.info("p: #{inspect(params)}")
  end

  defp set_final_jeopardy_clue(game) do
    clue_id =
      from(c in Clue,
        select: c.id,
        where: c.game_id == ^game.id,
        where: c.round == "final_jeopardy"
      )
      |> Repo.one()

    Game.changeset(game, %{current_clue_id: clue_id}) |> Repo.update()
  end

  defp zero_out_negative_scores(game) do
    from(p in Player,
      where: p.game_id == ^game.id,
      where: p.name != ^game.trebek,
      where: p.score < 0
    )
    |> Repo.update_all_ts(set: [score: 0])
  end
end
