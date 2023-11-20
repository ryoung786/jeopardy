defmodule Jeopardy.Game do
  @moduledoc false
  use TypedStruct

  alias Jeopardy.Board
  alias Jeopardy.Board.Clue
  alias Jeopardy.Contestant
  alias Jeopardy.FSM
  alias Jeopardy.FSM.AwaitingPlayers
  alias Jeopardy.FSM.Messages.ScoreUpdated
  alias Jeopardy.JArchive.RecordedGame

  typedstruct do
    field :code, String.t()
    field :round, :jeopardy | :double_jeopardy | :final_jeopardy, default: :jeopardy
    field :players, map(), default: %{}
    field :board, Board.t(), default: %Board{}
    field :trebek, String.t()
    field :contestants, map(), default: %{}
    field :jarchive_game, %RecordedGame{}
    field :fsm, %FSM{}, default: %FSM{state: AwaitingPlayers}
    field :clue, Clue.t()
    field :buzzer, String.t()
  end

  @spec set_board_control(game :: t(), name :: String.t()) :: t()
  def set_board_control(game, name) do
    with {:ok, _} <- find_contestant(game, name),
         do: %{game | board: %{game.board | control: name}}
  end

  @spec update_contestant_score(game :: t(), name :: String.t(), amount :: integer(), correct? :: boolean()) :: t()
  def update_contestant_score(game, name, amount, correct?) do
    with {:ok, _} <- find_contestant(game, name),
         do: set_contestant_score(game, name, game.contestants[name].score + amount, correct?)
  end

  @spec set_contestant_score(t(), String.t(), integer(), boolean()) :: integer()
  def set_contestant_score(game, name, amount, correct? \\ nil) do
    with {:ok, c} <- find_contestant(game, name) do
      correct? = if is_nil(correct?), do: amount >= c.score, else: correct?

      game.contestants[name].score
      |> put_in(amount)
      |> FSM.broadcast(%ScoreUpdated{contestant_name: name, from: c.score, to: amount, correct: correct?})
    end
  end

  defp find_contestant(game, name) do
    case Map.get(game.contestants, name) do
      %Contestant{} = c -> {:ok, c}
      nil -> {:error, :contestant_not_found}
    end
  end

  def contestants_lowest_to_highest_score(game, opts \\ []) do
    contestants =
      case Keyword.get(opts, :sort, :random) do
        :alphabetical -> Enum.sort_by(Map.values(game.contestants), & &1.name)
        _ -> Enum.shuffle(Map.values(game.contestants))
      end

    Enum.sort_by(contestants, & &1.score)
  end
end
