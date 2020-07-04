defmodule Jeopardy.FSM.Jeopardy.SelectingClue do
  use Jeopardy.FSM
  alias Jeopardy.Repo
  alias Jeopardy.Games.Game
  import Ecto.Query

  def handle(:clue_selected, clue_id, %State{} = state) do
    {:ok, retrieve_state(state.game.id)}
  end
end
