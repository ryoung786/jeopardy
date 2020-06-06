defmodule JeopardyWeb.ScoreboardView do
  use JeopardyWeb, :view

  def pre_score(%Jeopardy.Games.Player{} = p, %Jeopardy.Games.Game{} = game) do
    JeopardyWeb.TvView.pre_score(p, game)
  end

  def correct_final_jeopardy_answer?(%Jeopardy.Games.Player{} = p, %Jeopardy.Games.Game{} = game) do
    game.status == "final_jeopardy" and game.current_clue_id in p.correct_answers
  end
end
