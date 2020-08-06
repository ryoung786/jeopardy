defmodule Jeopardy.Drafts do
  @moduledoc """
  The Drafts context.
  """

  import Ecto.Query, warn: false
  alias Jeopardy.Repo

  alias Jeopardy.Drafts.Game

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(Game)
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id), do: Repo.get!(Game, id)

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{data: %Game{}}

  """
  def change_game(%Game{} = game, attrs \\ %{}) do
    Game.changeset(game, attrs)
  end

  def change_clue(%{} = clue, attrs \\ %{}) do
    Game.clue_changeset(clue, attrs)
  end

  def change_final_jeopardy_clue(fj_clue, attrs \\ %{}) do
    Game.final_jeopardy_changeset(fj_clue, attrs)
  end

  def update_final_jeopardy_clue(%Game{} = game, attrs) do
    fj_json = Map.get(game.clues, "final_jeopardy")

    with cs1 <- Game.final_jeopardy_changeset(%{}, fj_json),
         {true, _} <- {cs1.valid?, cs1},
         m <- Ecto.Changeset.apply_changes(cs1),
         cs2 <- Game.final_jeopardy_changeset(m, attrs),
         {true, _} <- {cs2.valid?, cs2},
         updated <- Ecto.Changeset.apply_changes(cs2) do
      updated_clues = update_in(game.clues, ["final_jeopardy"], &(&1 && updated))
      update_game(game, %{clues: updated_clues})
    else
      {false, cs} -> {:error, Map.put(cs, :action, :validate)}
    end
  end
end
