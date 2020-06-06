defmodule JeopardyWeb.ScoreboardView do
  use JeopardyWeb, :view

  def pre_score(%Jeopardy.Games.Player{} = p, fj_clue_id) do
    score(JeopardyWeb.TvView.pre_score(p, fj_clue_id))
  end
end
