defmodule Jeopardy.FSM.RevealingBoard do
  @moduledoc """
  :revealing_board ->
  """

  use Jeopardy.FSM.State

  @impl Jeopardy.FSM.State
  def initial_data(_game), do: %{revealed_category_count: 0}

  @impl true
  def valid_actions(), do: ~w/next_category/a

  @impl true
  def handle_action(:reveal_next_category, game, _args), do: reveal_next_category(game)

  defp reveal_next_category(%Jeopardy.Game{} = game) do
    idx = game.fsm.data.revealed_category_count

    if idx >= Enum.count(game.board.categories),
      do: {:ok, FSM.to_state(game, FSM.GameOver)},
      else: {:ok, update_in(game, [:fsm, :data, :revealed_category_count], &(&1 + 1))}
  end
end
