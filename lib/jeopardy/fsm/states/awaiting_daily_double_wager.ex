defmodule Jeopardy.FSM.AwaitingDailyDoubleWager do
  @moduledoc """
  awaiting daily double wager -> reading daily double clue
  """

  use Jeopardy.FSM.State
  alias Jeopardy.Game

  @wager_cap %{jeopardy: 1_000, double_jeopardy: 2_000}

  @impl true
  def valid_actions(), do: ~w/wagered/a

  @impl true
  def handle_action(:wagered, game, amount), do: wager(game, amount)

  defp wager(%Game{} = game, amount) do
    %{score: score} = game.contestants[game.board.control]

    with :ok <- validate_wager_amount(amount, score, game.round) do
      {:ok, put_in(game.clue.wager, amount) |> FSM.to_state(FSM.ReadingDailyDoubleClue)}
    end
  end

  defp validate_wager_amount(amount, score, round) do
    cap = max(score, @wager_cap[round])
    if amount in 5..cap, do: :ok, else: {:error, :wager_not_in_range}
  end
end
