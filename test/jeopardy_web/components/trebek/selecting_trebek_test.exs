defmodule JeopardyWeb.Components.Trebek.SelectingTrebekTest do
  use JeopardyWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Jeopardy.FSM.Messages.StatusChanged
  alias Jeopardy.FSM.Messages.TrebekSelected
  alias Jeopardy.GameServer

  setup do
    code = GameServer.new_game_server(game_id: "basic")
    GameServer.action(code, :add_player, "a")
    GameServer.action(code, :add_player, "b")
    GameServer.action(code, :add_player, "trebek")
    GameServer.action(code, :continue)

    [code: code]
  end

  describe "getting selected as the host" do
    test "congratulates the user", %{conn: conn, code: code} do
      conn = join_game(conn, code, "a")
      {:ok, lv, _html} = live(conn, ~p"/games/#{code}")

      Phoenix.PubSub.subscribe(Jeopardy.PubSub, "games:#{code}")

      lv |> element("button.unit-test-identifier") |> render_click()

      assert_received(%TrebekSelected{trebek: "a"})
      assert_received(%StatusChanged{to: _state})
      assert has_element?(lv, "div", "Congratulations, you'll be hosting this round of Jeopardy!")
    end
  end
end
