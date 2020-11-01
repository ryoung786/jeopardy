defmodule Jeopardy.FSM.Jeopardy.RevealingBoard do
  use Jeopardy.FSM
  alias Jeopardy.Repo
  alias Jeopardy.Games.Game
  alias Jeopardy.Games.Player
  import Ecto.Query

  @impl true
  def handle(:next, _, %State{} = state) do
    %{name: player_name} =
      state.contestants
      |> Enum.map(fn {_id, contestant} -> contestant end)
      |> player_with_lowest_score()

    updates = [
      board_control: player_name,
      round_status: "selecting_clue"
    ]

    from(g in Game, where: g.id == ^state.game.id)
    |> Repo.update_all_ts(set: updates)

    {:ok, retrieve_state(state.game.id)}
  end

  defp player_with_lowest_score(contestants) do
    # If there is a tie for the lowest score, pick one randomly
    # So first grab the lowest score
    %Player{score: lowest_score} = Enum.min_by(contestants, fn c -> c.score end)

    # then choose among players with that score randomly
    contestants
    |> Enum.filter(fn c -> c.score == lowest_score end)
    |> Enum.random()
  end
end
