defmodule Jeopardy.FSM.PreJeopardy.IntroducingRoles do
  use Jeopardy.FSM
  alias Jeopardy.Repo
  alias Jeopardy.Games.Game
  import Ecto.Query

  def handle(:next, _, %State{game: game}) do
    from(g in Game, where: g.id == ^game.id)
    |> Repo.update_all_ts(set: [status: "jeopardy", round_status: "revealing_board"])

    Jeopardy.Stats.create(game)
    {:ok, retrieve_state(game.id)}
  end
end
