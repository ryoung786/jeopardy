defmodule JeopardyWeb.Accounts.Drafts.GameLive.Edit.BoardComponent do
  use JeopardyWeb, :live_component
  require Logger

  defp edit_clue_path(socket, round, game, clue) do
    case round do
      "jeopardy" ->
        Routes.game_edit_jeopardy_path(socket, :edit_clue, game, Map.get(clue, "id"))

      "double_jeopardy" ->
        Routes.game_edit_double_jeopardy_path(socket, :edit_clue, game, Map.get(clue, "id"))
    end
  end
end
