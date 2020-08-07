defmodule JeopardyWeb.Accounts.Drafts.GameLive.Edit.BoardComponent do
  use JeopardyWeb, :live_component
  require Logger

  defp edit_category_path(socket, round, game, category_index) do
    round = sanitize_round(round)
    Routes.game_edit_jeopardy_path(socket, :edit_category, game, round, category_index)
  end

  defp edit_clue_path(socket, round, game, clue) do
    round = sanitize_round(round)
    Routes.game_edit_jeopardy_path(socket, :edit_clue, game, round, Map.get(clue, "id"))
  end

  defp sanitize_round(round), do: String.replace(round, "_", "-")
end
