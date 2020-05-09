defmodule JeopardyWeb.WagerView do
  use JeopardyWeb, :view
  alias Jeopardy.Games.Wager

  def changeset(min, max) do
    Wager.changeset(%Wager{}, %{}, min, max)
  end
end
