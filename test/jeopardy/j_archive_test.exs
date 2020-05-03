defmodule Jeopardy.JArchiveTest do
  use Jeopardy.DataCase

  alias Jeopardy.JArchive

  describe "games" do
    alias Jeopardy.JArchive.Archive

    @valid_attrs %{board_id: 42}
    @update_attrs %{board_id: 43}
    @invalid_attrs %{board_id: nil}

    def archive_fixture(attrs \\ %{}) do
      {:ok, archive} =
        attrs
        |> Enum.into(@valid_attrs)
        |> JArchive.create_archive()

      archive
    end

    test "list_games/0 returns all games" do
      archive = archive_fixture()
      assert JArchive.list_games() == [archive]
    end

    test "get_archive!/1 returns the archive with given id" do
      archive = archive_fixture()
      assert JArchive.get_archive!(archive.id) == archive
    end

    test "create_archive/1 with valid data creates a archive" do
      assert {:ok, %Archive{} = archive} = JArchive.create_archive(@valid_attrs)
      assert archive.board_id == 42
    end

    test "create_archive/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = JArchive.create_archive(@invalid_attrs)
    end

    test "update_archive/2 with valid data updates the archive" do
      archive = archive_fixture()
      assert {:ok, %Archive{} = archive} = JArchive.update_archive(archive, @update_attrs)
      assert archive.board_id == 43
    end

    test "update_archive/2 with invalid data returns error changeset" do
      archive = archive_fixture()
      assert {:error, %Ecto.Changeset{}} = JArchive.update_archive(archive, @invalid_attrs)
      assert archive == JArchive.get_archive!(archive.id)
    end

    test "delete_archive/1 deletes the archive" do
      archive = archive_fixture()
      assert {:ok, %Archive{}} = JArchive.delete_archive(archive)
      assert_raise Ecto.NoResultsError, fn -> JArchive.get_archive!(archive.id) end
    end

    test "change_archive/1 returns a archive changeset" do
      archive = archive_fixture()
      assert %Ecto.Changeset{} = JArchive.change_archive(archive)
    end
  end
end
