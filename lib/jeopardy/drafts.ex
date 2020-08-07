defmodule Jeopardy.Drafts do
  @moduledoc """
  The Drafts context.
  """

  import Ecto.Query, warn: false
  alias Jeopardy.Repo
  alias Jeopardy.Drafts.Game
  require Logger

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

  def change_category(%{} = category, attrs \\ %{}) do
    Game.category_changeset(category, attrs)
  end

  def change_clue(%{} = clue, attrs \\ %{}) do
    Game.clue_changeset(clue, attrs)
  end

  def change_final_jeopardy_clue(fj_clue, attrs \\ %{}) do
    Game.final_jeopardy_changeset(fj_clue, attrs)
  end

  def get_category!(%Game{} = game, category_id) when is_binary(category_id),
    do: get_category!(game, String.to_integer(category_id))

  def get_category!(%Game{} = game, category_id) do
    {categories, category_id} =
      if category_id < 6,
        do: {Map.get(game.clues, "jeopardy"), category_id},
        else: {Map.get(game.clues, "double_jeopardy"), category_id - 6}

    category_name = categories |> Enum.at(category_id) |> Map.get("category")
    %{category: category_name}

    # change_clue(%{}, clue) |> Ecto.Changeset.apply_changes()
  end

  def get_clue!(%Game{} = game, clue_id) when is_binary(clue_id),
    do: get_clue!(game, String.to_integer(clue_id))

  def get_clue!(%Game{} = game, clue_id) do
    categories =
      if clue_id <= 30,
        do: Map.get(game.clues, "jeopardy"),
        else: Map.get(game.clues, "double_jeopardy")

    clue =
      Enum.reduce(categories, [], fn x, acc ->
        acc ++ Map.get(x, "clues")
      end)
      |> List.flatten()
      |> Enum.find(&(Map.get(&1, "id") == clue_id))

    change_clue(%{}, clue) |> Ecto.Changeset.apply_changes()
  end

  def update_clue(%Game{} = game, clue_id, attrs) when is_integer(clue_id),
    do: update_clue(game, get_clue!(game, clue_id), attrs)

  def update_clue(%Game{} = game, %{} = clue, attrs) do
    with cs1 <- change_clue(clue, attrs),
         {true, _} <- {cs1.valid?, cs1},
         m <- Ecto.Changeset.apply_changes(cs1),
         cs2 <- change_clue(m, attrs),
         {true, _} <- {cs2.valid?, cs2},
         updated <- Ecto.Changeset.apply_changes(cs2) do
      updated = updated |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
      clue_id = Map.get(updated, "id")
      round = if clue_id <= 30, do: "jeopardy", else: "double_jeopardy"

      updated_clues =
        update_in(game.clues, [round], fn categories ->
          Enum.map(categories, fn category_obj ->
            clues = Map.get(category_obj, "clues")

            %{
              category_obj
              | "clues" =>
                  Enum.map(clues, fn clue ->
                    if clue_id == Map.get(clue, "id"),
                      do: updated,
                      else: clue
                  end)
            }
          end)
        end)

      update_game(game, %{clues: updated_clues})
    else
      {false, cs} -> {:error, Map.put(cs, :action, :validate)}
    end
  end

  def update_category(%Game{} = game, category_id, %{} = category, attrs) do
    category_json =
      if(category_id < 6,
        do: Map.get(game.clues, "jeopardy"),
        else: Map.get(game.clues, "double_jeopardy")
      )
      |> Enum.at(category_id)

    round = if category_id < 6, do: "jeopardy", else: "double_jeopardy"

    with cs <- change_category(category, attrs),
         {true, _} <- {cs.valid?, cs},
         updated <- Ecto.Changeset.apply_changes(cs) do
      updated = updated |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
      updated = Map.merge(category_json, updated)

      updated_clues =
        update_in(game.clues, [round], fn categories ->
          List.replace_at(categories, category_id, updated)
        end)

      update_game(game, %{clues: updated_clues})
    else
      {false, cs} -> {:error, Map.put(cs, :action, :validate)}
    end
  end

  def update_final_jeopardy_clue(%Game{} = game, attrs) do
    fj_json = Map.get(game.clues, "final_jeopardy")

    with cs1 <- Game.final_jeopardy_changeset(%{}, fj_json),
         {true, _} <- {cs1.valid?, cs1},
         m <- Ecto.Changeset.apply_changes(cs1),
         cs2 <- Game.final_jeopardy_changeset(m, attrs),
         {true, _} <- {cs2.valid?, cs2},
         updated <- Ecto.Changeset.apply_changes(cs2) do
      updated = updated |> Map.new(fn {k, v} -> {Atom.to_string(k), v} end)
      updated_clues = update_in(game.clues, ["final_jeopardy"], &(&1 && updated))
      update_game(game, %{clues: updated_clues})
    else
      {false, cs} -> {:error, Map.put(cs, :action, :validate)}
    end
  end
end
