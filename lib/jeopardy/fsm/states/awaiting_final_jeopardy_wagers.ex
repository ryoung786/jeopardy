defmodule Jeopardy.FSM.AwaitingFinalJeopardyWagers do
  @moduledoc """
  awaiting final jeopardy wagers -> reading final jeopardy clue
  """

  use Jeopardy.FSM.State
  alias Jeopardy.Game

  @impl true
  def valid_actions(), do: ~w/wagered_amount time_expired/a

  @impl true
  def handle_action(:wagered_amount, game, {contestant_name, amount}),
    do: wager(game, contestant_name, amount)

  def handle_action(:time_expired, game, _), do: time_expired(game)

  defp wager(%Game{} = _game, _contestant_name, _amount) do
    :todo
  end

  defp time_expired(_game) do
    :todo
  end
end
