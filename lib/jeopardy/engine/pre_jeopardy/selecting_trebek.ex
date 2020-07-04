defmodule Jeopardy.Engine.PreJeopardy.SelectingTrebek do
  use Jeopardy.Engine

  def handle(%{event: :trebek_selected, data: data}, %{game: game} = state) do
    Jeopardy.Games.assign_trebek(game, data.name)
  end
end
