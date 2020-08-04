defmodule Jeopardy.DraftsTest do
  use Jeopardy.DataCase

  alias Jeopardy.Drafts

  describe "games" do
    alias Jeopardy.Drafts.Game

    @valid_attrs %{
      clues: %{},
      description: "some description",
      format: "jeopardy",
      name: "some name",
      owner_id: 42,
      owner_type: "user",
      tags: []
    }
    @update_attrs %{
      clues: %{},
      description: "some updated description",
      format: "jeopardy",
      name: "some updated name",
      owner_id: 43,
      owner_type: "user",
      tags: []
    }
    @invalid_attrs %{
      clues: nil,
      description: nil,
      format: nil,
      name: nil,
      owner_id: nil,
      owner_type: nil,
      tags: nil
    }

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Drafts.create_game()

      game
    end

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Drafts.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Drafts.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      assert {:ok, %Game{} = game} = Drafts.create_game(@valid_attrs)
      assert game.clues == %{}
      assert game.description == "some description"
      assert game.format == "jeopardy"
      assert game.name == "some name"
      assert game.owner_id == 42
      assert game.owner_type == "user"
      assert game.tags == []
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Drafts.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      assert {:ok, %Game{} = game} = Drafts.update_game(game, @update_attrs)
      assert game.clues == %{}
      assert game.description == "some updated description"
      assert game.format == "jeopardy"
      assert game.name == "some updated name"
      assert game.owner_id == 43
      assert game.owner_type == "user"
      assert game.tags == []
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Drafts.update_game(game, @invalid_attrs)
      assert game == Drafts.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Drafts.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Drafts.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Drafts.change_game(game)
    end
  end
end
