defmodule JeopardyWeb.Components.Contestant.SelectingTrebekTest do
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

  describe "joining a game as a contestant" do
    test "gives you the option to volunteer as host", %{conn: conn, code: code} do
      conn = join_game(conn, code, "a")
      {:ok, _lv, html} = live(conn, ~p"/games/#{code}")
      assert html =~ "Volunteer to host"
    end
  end
end
