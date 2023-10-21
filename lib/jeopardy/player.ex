defmodule Jeopardy.Player do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field :name, String.t()
    field :signature, String.t()
  end
end

defimpl Inspect, for: Jeopardy.Player do
  def inspect(player, _opts) do
    "%Player{name: #{player.name}, signature: #{!!player.signature}}"
  end
end
