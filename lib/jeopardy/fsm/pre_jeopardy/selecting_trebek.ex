defmodule Jeopardy.FSM.PreJeopardy.SelectingTrebek do
  use Jeopardy.FSM
  alias Jeopardy.Games.Game

  def handle(%{event: :trebek_selected, data: data}, %{game: game}) do
    q =
      from g in Game,
        where: g.id == ^game.id,
        where: is_nil(g.trebek),
        where: g.round_status == "selecting_trebek",
        select: g.id

    updates = [
      trebek: data.name,
      round_status: "introducing_roles"
    ]

    Repo.update_all_ts(q, set: updates)

    retrieve_state(game.id)
  end
end
