defmodule JeopardyWeb.Accounts.Drafts.GameLive.Edit.BoardComponent do
  use JeopardyWeb, :live_component
  require Logger

  defp edit_clue_path(socket, round, game, clue) do
    round = String.replace(round, "_", "-")
    Routes.game_edit_jeopardy_path(socket, :edit_clue, game, round, Map.get(clue, "id"))
  end
end
