defmodule Jeopardy.FSM.GameOver do
  use Jeopardy.FSM.State

  alias Jeopardy.Game

  @impl true
  def initial_data(_game), do: %{revealed: []}

  @impl true
  def valid_actions(), do: ~w/revealed_contestant play_again/a

  @impl true
  def handle_action(:play_again, %Game{} = game, _data), do: play_again(game)

  def handle_action(:revealed_contestant, game, name), do: mark_revealed(game, name)

  defp mark_revealed(game, name) do
    {:ok, update_in(game.fsm.data.revealed, &[name | &1])}
  end

  defp play_again(game) do
    {:ok, %Game{code: game.code, players: game.players}}
  end
end
