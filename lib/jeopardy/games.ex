defmodule Jeopardy.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false

  alias Jeopardy.Games.Game
  alias Jeopardy.Games.Players.Player
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

  def start(code, player_names) do
    game = get_by_code(code)
    IO.inspect game
    player_names |> Enum.each(fn name -> add_player(game, name) end)
    update_game_status(code, "awaiting_start", "selecting_trebek")
  end

  defp update_game_status(code, from, to) do
    case (from g in Game, where: g.code == ^code and g.status == ^from, select: g.id)
    |> Repo.update_all(set: [status: to]) do
      {0, _} -> {:failed, nil}
      {1, [id]} ->
        Phoenix.PubSub.broadcast(Jeopardy.PubSub, code, {:game_status_change, to})
        {:ok, get_game!(id)}
    end
  end

  def assign_trebek(%Game{code: code} = game, name) do
    case (from g in Game, where: g.id == ^game.id and is_nil(g.trebek), select: g.id)
    |> Repo.update_all(set: [trebek: name]) do
      {0, _} -> {:failed, nil}
      {1, [_id]} ->
        # Phoenix.PubSub.broadcast(Jeopardy.PubSub, code, {:trebek_assigned, name})
        update_game_status(code, game.status, "round_one_intro")
    end
  end

  def get_just_contestants(%Game{} = game) do
    from(p in Player, where: p.game_id == ^game.id and p.name != ^game.trebek) |> Repo.all
  end

  def get_player(%Game{} = game, name) do
    from(p in Player, where: p.game_id == ^game.id and p.name == ^name) |> Repo.one
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

  def players(%Game{} = game), do: Repo.all Ecto.assoc(game, :players)

  def add_player(%Game{} = game, name) do
    Ecto.build_assoc(game, :players, %{name: name})
    |> Repo.insert()
  end

end
