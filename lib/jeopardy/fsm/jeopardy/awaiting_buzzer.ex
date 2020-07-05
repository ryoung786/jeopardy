defmodule Jeopardy.FSM.Jeopardy.AwaitingBuzzer do
  use Jeopardy.FSM
  alias Jeopardy.Repo
  alias Jeopardy.Games.Game
  import Ecto.Query

  @impl true
  def on_enter(state) do
    Jeopardy.Timer.start(state.game.code, 5)
    state
  end

  @impl true
  def handle(:buzz, player_id, %State{} = state) do
    buzz(player_id, state)
    {:ok, retrieve_state(state.game.id)}
  end

  defp buzz(player_id, state) do
    player = state.contestants[player_id]

    q =
      from g in Game,
        where: g.id == ^state.game.id,
        where: g.buzzer_lock_status == "clear",
        where: is_nil(g.buzzer_player),
        where: g.round_status == "awaiting_buzzer",
        join: c in Clue,
        on: c.id == g.current_clue_id,
        on: ^player.id not in c.incorrect_players,
        select: g.id

    updates = [
      buzzer_player: player.name,
      buzzer_lock_status: "player",
      round_status: "answering_clue"
    ]

    case Repo.update_all_ts(q, set: updates) do
      {0, _} ->
        {:failed, nil}

      {1, _} ->
        Jeopardy.Timer.stop(state.game.code)
        {:ok, nil}
    end
  end
end
