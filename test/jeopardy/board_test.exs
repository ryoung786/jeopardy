defmodule Jeopardy.BoardTest do
  use ExUnit.Case, asyc: true

  alias Jeopardy.Board

  describe "Board.from_game/2" do
    test "loads jeopardy round" do
      {:ok, jarchive_game} = Jeopardy.JArchive.load_game("basic")
      board = Board.from_game(jarchive_game, :jeopardy)

      assert board.categories == jarchive_game.categories.jeopardy
      assert board.clues["xyz"][500].answer == "bar"
    end

    test "loads double jeopardy round" do
      {:ok, jarchive_game} = Jeopardy.JArchive.load_game("basic")
      board = Board.from_game(jarchive_game, :double_jeopardy)

      assert board.categories == jarchive_game.categories.double_jeopardy
      assert board.clues["WORLD HISTORY"][200].answer == "Francisco Franco"
    end
  end
end
