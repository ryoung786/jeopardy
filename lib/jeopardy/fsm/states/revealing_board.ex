defmodule Jeopardy.FSM.RevealingBoard do
  @moduledoc """
  revealing board -> selecting clue
  """

  use Jeopardy.FSM.State
  alias Jeopardy.Game

  @impl true
  def initial_data(_game), do: %{revealed_category_count: 0}

  @impl true
  def valid_actions(), do: ~w/reveal_next_category/a

  @impl true
  def handle_action(:reveal_next_category, game, _args), do: reveal_next_category(game)

  defp reveal_next_category(%Jeopardy.Game{} = game) do
    if game.fsm.data.revealed_category_count < Enum.count(game.board.categories) do
      {:ok, update_in(game.fsm.data.revealed_category_count, &(&1 + 1))}
    else
      contestant = contestant_with_lowest_score(game)
      {:ok, game |> Game.set_board_control(contestant.name) |> FSM.to_state(FSM.SelectingClue)}
    end
  end

  defp contestant_with_lowest_score(%Game{} = game) do
    # If there is a tie for the lowest score, pick one randomly
    # So first grab the lowest score
    %{score: lowest_score} = game.contestants |> Map.values() |> Enum.min_by(& &1.score)

    # then choose among players with that score randomly
    game.contestants
    |> Map.values()
    |> Enum.filter(fn c -> c.score == lowest_score end)
    |> Enum.random()
  end
end
