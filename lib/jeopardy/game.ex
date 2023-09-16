defmodule Jeopardy.Game do
  defstruct code: nil,
            fsm_handler: Jeopardy.FSM.AwaitingPlayers,
            state: %{},
            round: :jeopardy,
            players: [],
            board: %{},
            trebek: nil,
            contestants: %{},
            jarchive_game: nil
end
