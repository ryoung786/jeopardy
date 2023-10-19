defmodule Jeopardy.FSM.Messages do
  @moduledoc "Collection of messages that can be broadcast."

  defmodule ScoreUpdated, do: defstruct([:contestant_name, :from, :to])
  defmodule PlayAgain, do: defstruct([])
  defmodule JArchiveGameLoaded, do: defstruct([:air_date, :comments])
  defmodule TrebekSelected, do: defstruct([:trebek])
  defmodule StatusChanged, do: defstruct([:from, :to])
  defmodule WagerSubmitted, do: defstruct([:name, :amount])
  defmodule PlayerAdded, do: defstruct([:name])
  defmodule PlayerRemoved, do: defstruct([:name])
  defmodule TimerStarted, do: defstruct([:expires_at])
  defmodule FinalJeopardyAnswerSubmitted, do: defstruct([:name, :response])
  defmodule RevealedCategory, do: defstruct([:index])
  defmodule FinalScoresRevealed, do: defstruct([])
end
