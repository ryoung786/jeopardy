defmodule Jeopardy.Game do
  alias Jeopardy.FSM
  alias Jeopardy.FSM.AwaitingPlayers

  defstruct code: nil,
            fsm: %FSM{state: AwaitingPlayers},
            round: :jeopardy,
            players: [],
            board: %{},
            trebek: nil,
            contestants: %{},
            jarchive_game: nil
end
