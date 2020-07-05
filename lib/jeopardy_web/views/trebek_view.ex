defmodule JeopardyWeb.TrebekView do
  use JeopardyWeb, :view

  def revealing_board_class(i, current) do
    case i do
      _ when i < current -> "processed"
      _ when i == current -> "active"
      _ -> "unprocessed"
    end
  end

  def contestant_from_name(contestants, name) do
    {_id, contestant} = Enum.find(contestants, fn {_, v} -> v.name == name end)
    contestant
  end
end
