defmodule Jeopardy.Game do
  defstruct code: nil,
            status: :awaiting_players,
            round: :jeopardy,
            players: [],
            board: %{},
            trebek: nil,
            contestants: %{},
            jarchive_game: nil
end
