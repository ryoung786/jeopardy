defmodule Jeopardy.BoardTest do
  use ExUnit.Case, asyc: true

  alias Jeopardy.Board

  describe "Board.from_game/2" do
    test "loads jeopardy round" do
      {:ok, jarchive_game} = Jeopardy.JArchive.load_game(1)
      board = Board.from_game(jarchive_game, :jeopardy)

      assert board.categories == jarchive_game.categories.jeopardy
      assert board.clues["ROOM"][400].answer == "the basement"
    end

    test "loads double jeopardy round" do
      {:ok, jarchive_game} = Jeopardy.JArchive.load_game(1)
      board = Board.from_game(jarchive_game, :double_jeopardy)

      assert board.categories == jarchive_game.categories.double_jeopardy
      assert board.clues["TRANSPORTATION"][800].answer == "carbon"
    end
  end
end
