defmodule Jeopardy.FSM.AwaitingFinalJeopardyWagers do
  @moduledoc """
  awaiting final jeopardy wagers -> reading final jeopardy clue
  """

  use Jeopardy.FSM.State
  alias Jeopardy.Game

  @impl true
  def valid_actions(), do: ~w/wagered time_expired/a

  @impl true
  def handle_action(:wagered, game, {contestant_name, amount}),
    do: wager(game, contestant_name, amount)

  def handle_action(:time_expired, game, _), do: time_expired(game)

  defp wager(%Game{} = game, name, amount) do
    with :ok <- validate_contestant_exists(game, name),
         :ok <- validate_amount(amount, game.contestants[name]) do
      game = put_in(game.contestants[name].final_jeopardy_wager, amount)

      if Enum.any?(Map.values(game.contestants), &(&1.final_jeopardy_wager == nil)),
        do: {:ok, game},
        else: {:ok, FSM.to_state(game, FSM.ReadingFinalJeopardyClue)}
    end
  end

  defp time_expired(game) do
    # set any nil wagers to zero
    contestants =
      game.contestants
      |> Map.new(fn
        {name, %{final_jeopardy_wager: nil} = c} -> {name, %{c | final_jeopardy_wager: 0}}
        {name, c} -> {name, c}
      end)

    {:ok, %{game | contestants: contestants}}
  end

  defp validate_contestant_exists(game, name) do
    if Map.has_key?(game.contestants, name),
      do: :ok,
      else: {:error, :contestant_does_not_exist}
  end

  defp validate_amount(amount, %{score: score}) when amount < score, do: :ok
  defp validate_amount(_, _), do: {:error, :wager_is_more_than_contestant_score}
end
