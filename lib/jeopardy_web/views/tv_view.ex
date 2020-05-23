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
end
