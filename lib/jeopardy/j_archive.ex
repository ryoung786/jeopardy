defmodule Jeopardy.JArchive do
  @moduledoc """
  The JArchive context.
  """

  import Ecto.Query, warn: false
  alias Jeopardy.Repo
  alias Jeopardy.JArchive.Game, as: JGame
  alias Jeopardy.JArchive.Clue, as: JClue
  alias Jeopardy.Games.{Game, Clue}

  def random_game() do
    # we use the count of the number of valid games to create a random offset
    num_games = (from g in JGame, select: count(g.id), where: not is_nil(g.final_jeopardy_category)) |> Repo.one()
    offset = :rand.uniform(num_games)-1

    JGame
    |> where([g], not is_nil(g.final_jeopardy_category))
    |> offset(^offset)
    |> limit(1)
    |> preload([c], [:clues])
    |> Repo.one
  end

  def specific_game(id), do: Repo.get!(JGame, id)

  def clues_by_category(%JGame{} = game, round) when round in [:jeopardy, :double_jeopardy] do
    clues = from(c in JClue,
      where: c.game_id == ^game.id,
      where: c.round == ^Atom.to_string(round),
      order_by: [asc: c.value])
      |> Repo.all
    Enum.map(game.jeopardy_round_categories, fn category ->
      [category: category,
       clues: clues |> Enum.filter(fn clue -> clue.category == category end)]
    end)
  end

  def final_jeopardy_clue(%JGame{} = game) do
    from(c in JClue,
      where: c.game_id == ^game.id,
      where: c.round == "final_jeopardy")
    |> Repo.one
  end

  def load_into_game(%Game{} = game) do
    jgame = random_game()
    case load_into_game_changeset(game, jgame) |> Repo.update do
      {:ok, game} ->
        load_clues(game, jgame)
        game
      _ -> :error
    end
  end

  defp load_into_game_changeset(game, jgame) do
    Game.changeset(
      game,
      Map.from_struct(jgame) |> Map.put(:jarchive_game_id, jgame.id)
    )
  end

  defp load_clues(%Game{} = game, %JGame{} = jgame) do
    clues = Enum.map(jgame.clues, fn jclue ->
      clue =
        Clue.changeset(%Clue{}, Map.from_struct(jclue))
        |> Ecto.Changeset.apply_changes()

      Ecto.build_assoc(game, :clues, clue)
      |> Map.from_struct
      |> Map.drop([:__meta__, :game, :id])
    end)
    Repo.insert_all(Clue, clues, [], :with_timestamps)
  end
end
