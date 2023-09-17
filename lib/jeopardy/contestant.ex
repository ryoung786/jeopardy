defmodule Jeopardy.Contestant do
  use TypedStruct

  typedstruct do
    field :name, String.t()
    field :score, integer(), default: 0
    field :final_jeopardy_wager, non_neg_integer()
    field :final_jeopardy_answer, String.t()
    field :final_jeopardy_correct?, boolean(), default: false
  end
end
