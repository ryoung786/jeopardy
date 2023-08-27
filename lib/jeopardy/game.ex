defmodule Jeopardy.Game do
  defstruct status: :awaiting_players, players: [], board: %{}, trebek: nil, contestants: %{}
end
