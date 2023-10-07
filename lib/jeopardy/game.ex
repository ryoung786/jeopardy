defmodule Jeopardy.Game do
  use TypedStruct

  alias Jeopardy.Board
  alias Jeopardy.Board.Clue
  alias Jeopardy.Contestant
  alias Jeopardy.JArchive.RecordedGame
  alias Jeopardy.FSM
  alias Jeopardy.FSM.AwaitingPlayers

  typedstruct do
    field :code, String.t()
    field :round, :jeopardy | :double_jeopardy | :final_jeopardy, default: :jeopardy
    field :players, [String.t()], default: []
    field :board, Board.t(), default: %Board{}
    field :trebek, String.t()
    field :contestants, map(), default: %{}
    field :jarchive_game, %RecordedGame{}
    field :fsm, %FSM{}, default: %FSM{state: AwaitingPlayers}
    field :clue, Clue.t()
    field :buzzer, String.t()
  end

  @spec set_board_control(t(), String.t()) :: t()
  def set_board_control(game, name) do
    with {:ok, _} <- find_contestant(game, name),
         do: %{game | board: %{game.board | control: name}}
  end

  @spec update_contestant_score(t(), String.t(), integer()) :: integer()
  def update_contestant_score(game, name, amount) do
    with {:ok, _} <- find_contestant(game, name),
         do: update_in(game.contestants[name].score, &(&1 + amount))
  end

  @spec set_contestant_score(t(), String.t(), integer()) :: integer()
  def set_contestant_score(game, name, amount) do
    with {:ok, _} <- find_contestant(game, name) do
      put_in(game.contestants[name].score, amount)
      |> FSM.broadcast({:score_updated, {name, amount}})
    end
  end

  defp find_contestant(game, name) do
    case Map.get(game.contestants, name) do
      %Contestant{} = c -> {:ok, c}
      nil -> {:error, :contestant_not_found}
    end
  end
end
