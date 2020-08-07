defmodule JeopardyWeb.GameLiveTest do
  use JeopardyWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Jeopardy.Drafts

  @create_attrs %{
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
    owner_id: 42,
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

  defp fixture(:game) do
    {:ok, game} = Drafts.create_game(@create_attrs)
    game
  end

  defp fixture(:user, user) do
    Jeopardy.Repo.insert(user)
  end

  defp create_game(%{conn: conn}) do
    user = %Jeopardy.Users.User{email: "admin@foo.com", id: 42}
    conn = Pow.Plug.assign_current_user(conn, user, otp_app: :my_app)
    game = fixture(:game)
    fixture(:user, user)
    %{game: game, conn: conn}
  end

  describe "Index" do
    setup [:create_game]

    test "lists all games", %{conn: conn, game: game} do
      {:ok, _index_live, html} = live(conn, Routes.game_index_path(conn, :index))

      assert html =~ "Listing Games"
      assert html =~ game.description
    end

    test "saves new game", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.game_index_path(conn, :index))

      assert index_live |> element("a", "New Game") |> render_click() =~
               "New Game"

      assert_patch(index_live, Routes.game_index_path(conn, :new))

      assert index_live
             |> form("#game-form",
               game: Map.drop(@invalid_attrs, [:tags, :clues, :format, :owner_id, :owner_type])
             )
             |> render_change() =~ "can&apos;t be blank"

      # {:ok, _, html} =
      index_live
      |> form("#game-form",
        game: Map.drop(@create_attrs, [:tags, :clues, :format, :owner_id, :owner_type])
      )
      |> render_submit()

      # |> follow_redirect(conn, Routes.game_index_path(conn, :index))
      # |> follow_redirect(conn, Routes.game_edit_jeopardy_path(conn, :edit, game))

      # assert html =~ "Game created successfully"
      # assert html =~ "some description"
    end

    @tag :skip
    test "updates game in listing", %{conn: conn, game: game} do
      {:ok, index_live, _html} = live(conn, Routes.game_index_path(conn, :index))

      assert index_live |> element("#game-#{game.id} a", "Edit") |> render_click() =~
               "Edit Game"

      assert_patch(index_live, Routes.game_index_path(conn, :edit, game))

      assert index_live
             |> form("#game-form", game: Map.drop(@invalid_attrs, [:tags, :clues]))
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#game-form", game: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.game_index_path(conn, :index))

      assert html =~ "Game updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes game in listing", %{conn: conn, game: game} do
      {:ok, index_live, _html} = live(conn, Routes.game_index_path(conn, :index))

      assert index_live |> element("#game-#{game.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#game-#{game.id}")
    end
  end

  describe "Show" do
    setup [:create_game]

    test "displays game", %{conn: conn, game: game} do
      {:ok, _show_live, html} = live(conn, Routes.game_show_path(conn, :show, game))

      assert html =~ "Show Game"
      assert html =~ game.description
    end

    test "updates game within modal", %{conn: conn, game: game} do
      {:ok, show_live, _html} = live(conn, Routes.game_show_path(conn, :show, game))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Game"

      assert_patch(show_live, Routes.game_show_path(conn, :edit, game))

      assert show_live
             |> form("#game-form",
               game: Map.drop(@invalid_attrs, [:tags, :clues, :format, :owner_id, :owner_type])
             )
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#game-form",
          game: Map.drop(@update_attrs, [:tags, :clues, :format, :owner_id, :owner_type])
        )
        |> render_submit()
        |> follow_redirect(conn, Routes.game_show_path(conn, :show, game))

      assert html =~ "Game updated successfully"
      assert html =~ "some updated description"
    end
  end
end
