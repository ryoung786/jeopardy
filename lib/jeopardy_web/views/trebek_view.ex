defmodule JeopardyWeb.TrebekView do
  use JeopardyWeb, :view

  def revealing_board_class(i, current) do
    case i do
      _ when i < current -> "processed"
      _ when i == current -> "active"
      _ -> "unprocessed"
    end
  end
end
