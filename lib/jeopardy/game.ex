defmodule Jeopardy.Game do
  defstruct code: nil,
            status: :awaiting_players,
            state_data: %{},
            round: :jeopardy,
            players: [],
            board: %{},
            trebek: nil,
            contestants: %{},
            jarchive_game: nil
end
