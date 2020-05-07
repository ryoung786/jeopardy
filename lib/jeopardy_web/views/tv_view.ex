defmodule JeopardyWeb.TvView do
  use JeopardyWeb, :view
  require Calendar

  def format_air_date(date) do
    case Calendar.Strftime.strftime(date, "%B, %Y") do
      {:ok, formatted_date} -> formatted_date
      _ -> date
    end
  end
end
