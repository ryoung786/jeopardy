defmodule Jeopardy.FSM.AwaitingFinalJeopardyWagers do
  @moduledoc """
  awaiting final jeopardy wagers -> reading final jeopardy clue
  """

  use Jeopardy.FSM.State
  alias Jeopardy.Game
  alias Jeopardy.Timers

  @timer_seconds 30

  @impl true
  def valid_actions(), do: ~w/wagered awaiting_final_jeopardy_wagers_time_expired/a

  @impl true
  def initial_data(game) do
    {:ok, tref} =
      :timer.apply_after(:timer.seconds(@timer_seconds), Jeopardy.GameServer, :action, [
        game.code,
        :awaiting_final_jeopardy_wagers_time_expired,
        nil
      ])

    %{expires_at: Timers.add(@timer_seconds), tref: tref}
  end

  @impl true
  def handle_action(:wagered, game, {contestant_name, amount}) do
    wager(game, contestant_name, amount)
  end

  def handle_action(:awaiting_final_jeopardy_wagers_time_expired, game, _), do: time_expired(game)

  defp wager(%Game{} = game, name, amount) do
    with :ok <- validate_contestant_exists(game, name),
         :ok <- validate_amount(amount, game.contestants[name]) do
      game = put_in(game.contestants[name].final_jeopardy_wager, amount)

      if Enum.any?(Map.values(game.contestants), &(&1.final_jeopardy_wager == nil)) do
        FSM.broadcast(game, {:wager_submitted, {name, amount}})
        {:ok, game}
      else
        :timer.cancel(game.fsm.data.tref)
        {:ok, FSM.to_state(game, FSM.ReadingFinalJeopardyClue)}
      end
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

    {:ok, %{game | contestants: contestants} |> FSM.to_state(FSM.ReadingFinalJeopardyClue)}
  end

  defp validate_contestant_exists(game, name) do
    if Map.has_key?(game.contestants, name),
      do: :ok,
      else: {:error, :contestant_does_not_exist}
  end

  defp validate_amount(amount, %{score: score}) do
    cond do
      amount < 0 -> {:error, :negative_wager}
      amount > score -> {:error, :wager_exceeds_score}
      true -> :ok
    end
  end
end
