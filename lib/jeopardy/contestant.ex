defmodule Jeopardy.Contestant do
  @moduledoc false
  use TypedStruct

  alias Jeopardy.Player

  @derive {Inspect, except: [:signature]}

  typedstruct do
    field :name, String.t()
    field :score, integer(), default: 0
    field :signature, String.t()
    field :final_jeopardy_wager, non_neg_integer()
    field :final_jeopardy_answer, String.t()
    field :final_jeopardy_correct?, boolean(), default: false
  end

  def new(%Player{} = player) do
    %__MODULE__{name: player.name, signature: player.signature}
  end
end
