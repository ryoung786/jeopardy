defmodule Jeopardy.Board.Clue do
  use TypedStruct

  typedstruct do
    field :category, String.t()
    field :clue, String.t()
    field :answer, String.t()
    field :value, pos_integer()
    field :asked?, boolean(), default: false
    field :daily_double?, boolean(), default: false
    field :wager, pos_integer()
    field :incorrect_contestants, [String.t()], default: []
  end
end
