defmodule JeopardyWeb.TvView do
  use JeopardyWeb, :view
  require Calendar

  def format_air_date(date) do
    case Calendar.Strftime.strftime(date, "%B, %Y") do
      {:ok, formatted_date} -> formatted_date
      _ -> date
    end
  end

  def revealing_board_class(i, current) do
    case i do
      _ when i < current -> "processed"
      _ when i == current -> "active"
      _ -> "unprocessed"
    end
  end

  def order_by_pre_fj_score(contestants, %Jeopardy.Games.Game{} = game) do
    Enum.sort_by(contestants, fn contestant -> pre_score(contestant, game.current_clue_id) end)
  end

  def pre_score(%Jeopardy.Games.Player{} = p, fj_clue_id) do
    if fj_clue_id in p.correct_answers,
      do: p.score - p.final_jeopardy_wager,
      else: p.score + p.final_jeopardy_wager
  end
end
