defmodule JeopardyWeb.GameView do
  use JeopardyWeb, :view
  require Logger

  def buzzer_locked_by_early_buzz?(player_id) do
    Logger.warn("[xxx] blah blah view called #{inspect(player_id)}")
    Jeopardy.Games.Player.buzzer_locked_by_early_buzz?(player_id)
  end
end
