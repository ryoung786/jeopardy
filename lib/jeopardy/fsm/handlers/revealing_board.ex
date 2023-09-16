defmodule Jeopardy.FSM.RevealingBoard do
  @moduledoc """
  :revealing_board ->
  """

  use Jeopardy.FSM.Handler
  alias Jeopardy.FSM.RevealingBoard

  def initial_state(), do: %{revealed_category_count: 0}

  @impl true
  def valid_actions(), do: ~w/next_category/a

  @impl true
  def handle_action(:reveal_next_category, game, _args), do: reveal_next_category(game)

  defp reveal_next_category(%Jeopardy.Game{} = game) do
    # idx = Map.get(game.state_data, :revealed_category_count)

    {:ok, %{game | fsm_handler: RevealingBoard}}
  end
end
