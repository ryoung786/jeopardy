defmodule Jeopardy.FSM.GameOver do
  use Jeopardy.FSM.State

  alias Jeopardy.Game

  @impl true
  def valid_actions(), do: ~w/play_again/a

  @impl true
  def handle_action(:play_again, %Game{} = game, _data), do: {:ok, game}
end
