defmodule Jeopardy.Game do
  use TypedStruct

  alias Jeopardy.Board
  alias Jeopardy.JArchive.RecordedGame
  alias Jeopardy.FSM
  alias Jeopardy.FSM.AwaitingPlayers

  typedstruct do
    field :code, String.t()
    field :round, :jeopardy | :double_jeopardy | :final_jeopardy, default: :jeopardy
    field :players, [String.t()], default: []
    field :board, %Board{}, default: %Board{}
    field :trebek, String.t()
    field :contestants, map(), default: %{}
    field :jarchive_game, %RecordedGame{}
    field :fsm, %FSM{}, default: %FSM{state: AwaitingPlayers}
  end
end
