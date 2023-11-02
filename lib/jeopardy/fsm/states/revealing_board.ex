defmodule Jeopardy.FSM.RevealingBoard do
  @moduledoc """
  revealing board -> selecting clue
  """

  use Jeopardy.FSM.State

  alias Jeopardy.FSM.Messages.RevealedCategory
  alias Jeopardy.Game

  @impl true
  def initial_data(_game), do: %{revealed_category_count: 0}

  @impl true
  def valid_actions, do: ~w/reveal_next_category/a

  @impl true
  def handle_action(:reveal_next_category, game, _args), do: reveal_next_category(game)

  defp reveal_next_category(%Jeopardy.Game{} = game) do
    if game.fsm.data.revealed_category_count < Enum.count(game.board.categories) do
      FSM.broadcast(game, %RevealedCategory{index: game.fsm.data.revealed_category_count})
      {:ok, update_in(game.fsm.data.revealed_category_count, &(&1 + 1))}
    else
      contestant = game |> Game.contestants_lowest_to_highest_score() |> List.first()
      {:ok, game |> Game.set_board_control(contestant.name) |> FSM.to_state(FSM.SelectingClue)}
    end
  end
end
