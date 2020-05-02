defmodule Jeopardy.GameRoom do
  @moduledoc false
  alias Jeopardy.Cache

  def new() do
    generateGameCode()
    |> Cache.create()
  end

  @doc """
  Returns a random 4-letter code
  """
  def generateGameCode() do
    "ABCD"
  end
end
