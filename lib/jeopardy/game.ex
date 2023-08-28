defmodule Jeopardy.Game do
  defstruct code: nil,
            status: :awaiting_players,
            players: [],
            board: %{},
            trebek: nil,
            contestants: %{}
end
