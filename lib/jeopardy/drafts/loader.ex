defmodule Jeopardy.Drafts.Loader do
  alias Jeopardy.Drafts.Game, as: DGame
  alias Jeopardy.Games.Game, as: Game
  alias Jeopardy.Games.Clue
  alias Jeopardy.Repo

  def load_into_game(%DGame{} = dgame, %Game{} = game) do
    category_names = categories(dgame)

    game_data = %{
      jarchive_game_id: dgame.id,
      air_date: dgame.inserted_at,
      jeopardy_round_categories: category_names.jeopardy,
      double_jeopardy_round_categories: category_names.double_jeopardy,
      final_jeopardy_category: category_names.final_jeopardy
    }

    with {:ok, game} <-
           Game.changeset(
             game,
             dgame |> Map.merge(game_data) |> Map.from_struct()
           )
           |> Repo.update(),
         {num, _} when is_integer(num) <- load_clues(dgame, game) do
      {:ok, game}
    else
      {:error, cs} -> {:error, cs}
    end
  end

  defp categories(dgame) do
    %{
      jeopardy: dgame.clues["jeopardy"] |> get_category_name(),
      double_jeopardy: dgame.clues["double_jeopardy"] |> get_category_name,
      final_jeopardy: dgame.clues["final_jeopardy"]["category"]
    }
  end

  defp get_category_name(x), do: Enum.map(x, & &1["category"])

  defp load_clues(%DGame{} = dgame, %Game{} = game) do
    clues =
      map_clues(dgame, "jeopardy") ++
        map_clues(dgame, "double_jeopardy") ++
        map_clues(dgame, "final_jeopardy")

    clues =
      Enum.map(clues, fn c ->
        clue =
          Clue.changeset(%Clue{}, c)
          |> Ecto.Changeset.apply_changes()

        Ecto.build_assoc(game, :clues, clue)
        |> Map.from_struct()
        |> Map.drop([:__meta__, :game, :id])
      end)

    Repo.insert_all(Clue, clues, [], :with_timestamps)
  end

  defp map_clues(%DGame{} = dgame, "final_jeopardy" = round) do
    fj = dgame.clues[round] |> Map.put("type", "final_jeopardy")
    [map_clue_json(fj, fj["category"], round)]
  end

  defp map_clues(%DGame{} = dgame, round) do
    categories = dgame.clues[round]

    categories
    |> Enum.flat_map(fn cat ->
      cat_name = cat["category"]

      Enum.map(cat["clues"], &map_clue_json(&1, cat_name, round))
    end)
  end

  defp map_clue_json(clue, cat_name, round) do
    %{
      category: cat_name,
      round: round,
      clue_text: clue["clue"],
      answer_text: clue["answer"],
      value: clue["value"],
      type: clue["type"]
    }
  end
end
