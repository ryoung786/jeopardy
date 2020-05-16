defmodule Jeopardy.JArchive do
  @moduledoc """
  The JArchive context.
  """

  import Ecto.Query, warn: false
  alias Jeopardy.Repo
  alias Jeopardy.Games.{Game, Clue}

  @archive_dir Path.join(:code.priv_dir(:jeopardy), "jarchive")

  def random_game() do
    Path.wildcard(Path.join(@archive_dir, "*.json"))
    |> Enum.random
    |> File.read!
    |> Jason.decode!
  end

  def specific_game(id), do: Jason.decode!(File.read!(Path.join(@archive_dir, "#{id}.json")))

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
      game, jgame |> Map.put("jarchive_game_id", jgame["id"])
    )
  end

  defp load_clues(%Game{} = game, jgame) do
    clues = jgame["jeopardy"] ++ jgame["double_jeopardy"] ++ [jgame["final_jeopardy"]]
    clues = Enum.map(clues, fn jclue ->
      clue =
        Clue.changeset(%Clue{}, jclue)
        |> Ecto.Changeset.apply_changes()

      Ecto.build_assoc(game, :clues, clue)
      |> Map.from_struct
      |> Map.drop([:__meta__, :game, :id])
    end)
    Repo.insert_all(Clue, clues, [], :with_timestamps)
  end
end
