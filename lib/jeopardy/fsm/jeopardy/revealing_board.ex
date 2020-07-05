defmodule Jeopardy.FSM.Jeopardy.RevealingBoard do
  use Jeopardy.FSM
  alias Jeopardy.Repo
  alias Jeopardy.Games.Game
  import Ecto.Query

  @impl true
  def handle(:next, _, %State{} = state) do
    {_, %{name: player_name}} = Enum.random(state.contestants)

    updates = [
      board_control: player_name,
      round_status: "selecting_clue"
    ]

    from(g in Game, where: g.id == ^state.game.id)
    |> Repo.update_all_ts(set: updates)

    {:ok, retrieve_state(state.game.id)}
  end
end
