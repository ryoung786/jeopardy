defmodule Jeopardy.FSM.Jeopardy.ReadingClue do
  import Ecto.Query, warn: false
  alias Jeopardy.Games.Game
  alias Jeopardy.Repo

  def handle(_, _, %Game{} = g) do
    clear_buzzer_and_update_round(g)
    Jeopardy.Timer.start(g.code, 5)
  end

  defp clear_buzzer_and_update_round(%Game{} = game) do
    (from g in Game,
      where: g.id == ^game.id,
      where: g.round_status == "reading_clue")
    |> Repo.update_all_ts(set: [buzzer_player: nil,
                               buzzer_lock_status: "clear",
                               round_status: "awaiting_buzzer"])
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, game.code,
      {:round_status_change, "awaiting_buzzer"})
  end
end
