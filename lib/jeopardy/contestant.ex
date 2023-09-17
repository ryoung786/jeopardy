defmodule Jeopardy.Contestant do
  use TypedStruct

  typedstruct do
    field :name, String.t()
    field :score, integer(), default: 0
  end
end
