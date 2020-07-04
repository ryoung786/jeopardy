defmodule Jeopardy.FSM.PreJeopardy.SelectingTrebek do
  use Jeopardy.FSM
  alias Jeopardy.Games.Game

  def handle(:select_trebek, player_id, %State{game: game} = state) do
    player = state.contestants[player_id]

    q =
      from g in Game,
        where: g.id == ^game.id,
        where: is_nil(g.trebek),
        where: g.round_status == "selecting_trebek",
        select: g.id

    updates = [
      trebek: player.name,
      round_status: "introducing_roles"
    ]

    Repo.update_all_ts(q, set: updates)

    {:ok, retrieve_state(game.id)}
  end
end
