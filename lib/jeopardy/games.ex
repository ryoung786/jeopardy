defmodule Jeopardy.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false

  alias Jeopardy.Games.Game
  alias Jeopardy.Repo

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

  def get_by_code(code), do: Repo.get_by(Game, code: code)

  @doc """
  Creates a game.

  ## Examples

      iex> create()
      {:ok, %Game{}}

      iex> create()
      {:error, %Ecto.Changeset{}}

  """
  def create() do
    %Game{}
    |> Game.changeset(%{code: generateGameCode()})
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

  _ = """
  Returns a random 4-letter code
  """
  defp generateGameCode() do
    chars = "ABCDEFGHJKMNPQRSTUVWXYZ" |> String.split("", trim: true)

    Enum.reduce((1..4), [], fn (_i, acc) ->
      [Enum.random(chars) | acc]
    end) |> Enum.join("")
  end

  def buzzer(%Game{code: code}, name), do: buzzer(code, name)
  def buzzer(code, name) do
    case (from g in Game, where: g.code == ^code and is_nil(g.buzzer), select: g.id)
    |> Repo.update_all(set: [buzzer: name]) do
      {0, _} -> {:failed, nil}
      {1, [id]} ->
        Phoenix.PubSub.broadcast(Jeopardy.PubSub, code, {:buzz, name})
        {:ok, get_game!(id)}
    end
  end
  def clear_buzzer(%Game{code: code}), do: clear_buzzer(code)
  def clear_buzzer(code) do
    {_num, [id]} = (from g in Game, where: g.code == ^code, select: g.id)
    |> Repo.update_all(set: [buzzer: nil])
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, code, :clear)
    get_game!(id)
  end

end
