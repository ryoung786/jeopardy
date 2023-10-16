defmodule JeopardyWeb.Components.Tv.SelectingTrebekTest do
  use JeopardyWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Jeopardy.GameServer

  setup do
    code = GameServer.new_game_server(game_id: "basic")
    GameServer.action(code, :add_player, "a")
    GameServer.action(code, :add_player, "b")
    GameServer.action(code, :add_player, "trebek")
    GameServer.action(code, :continue)

    [code: code]
  end

  describe "viewing as the TV" do
    test "prompts to select a host", %{conn: conn, code: code} do
      {:ok, _lv, html} = live(conn, ~p"/games/#{code}")
      assert html =~ "Please select a player to host"
    end
  end
end
