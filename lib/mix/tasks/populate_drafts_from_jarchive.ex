defmodule Mix.Tasks.PopulateDraftsFromJarchive do
  use Mix.Task
  alias Jeopardy.Drafts
  require Logger

  @shortdoc "Create draft games from jarchive json files"

  def run(args) do
    Mix.Task.run("app.start")
    get_files(args) |> process_files()
  end

  def get_files([_ | _] = ids), do: Enum.map(ids, fn id -> "#{id}.json" end)

  def get_files([]) do
    {:ok, files} = File.ls(archive_path())
    files
  end

  def process_files(files) do
    path = archive_path()

    Enum.with_index(files)
    |> Enum.each(fn {file, i} ->
      if rem(i, 100) == 0, do: Logger.warn("processed #{i} files")

      with {:ok, f} <- File.read(Path.join(path, file)) do
        process_file(f, i)
      else
        _ -> Logger.error("Couldn't find #{file}")
      end
    end)
  end

  def process_file(f, _i) do
    json = Jason.decode!(f)

    Drafts.create_game(%{
      owner_id: 0,
      owner_type: "jarchive",
      name: "Show ##{json["episode_num"]}",
      description: desc_from_json(json),
      tags: tags_from_json(json),
      format: "jeopardy",
      clues: clues_from_json(json)
    })
  end

  def desc_from_json(json) do
    case String.trim(json["description"]) do
      "" -> "#{json["air_date"]}"
      _ -> "#{json["air_date"]}: #{json["description"]}" |> String.slice(0, 200)
    end
  end

  def tags_from_json(json), do: json["contestants"] |> Enum.map(&String.slice(&1, 0, 200))

  def clues_from_json(json) do
    json = add_clue_ids(json)

    %{
      jeopardy: get_clues(json, "jeopardy"),
      double_jeopardy: get_clues(json, "double_jeopardy"),
      final_jeopardy: get_final_jeopardy_clue(json)
    }
  end

  def get_clues(json, round) when round in ~w(jeopardy double_jeopardy),
    do: get_clues(json[round], json["#{round}_round_categories"])

  def get_clues(json, categories) do
    m =
      json
      |> Enum.group_by(& &1["category"])
      |> Enum.map(fn {cat_name, clues} ->
        {cat_name, Enum.map(clues, &convert_clue/1)}
      end)
      |> Enum.into(%{})

    Enum.map(categories, &%{category: &1, clues: m[&1]})
  end

  def get_final_jeopardy_clue(json) do
    fj = json["final_jeopardy"]

    %{
      answer: fj["answer_text"],
      category: fj["category"],
      clue: fj["clue_text"]
    }
  end

  def convert_clue(json) do
    %{
      answer: json["answer_text"],
      clue: json["clue_text"],
      value: json["value"],
      type: json["type"],
      id: json["id"]
    }
  end

  def add_clue_ids(json) do
    Map.put(
      json,
      "jeopardy",
      json["jeopardy"]
      |> Enum.sort(fn a, b ->
        if a["category"] == b["category"],
          do: a["value"] < b["value"],
          else: a["category"] < b["category"]
      end)
      |> Enum.with_index(1)
      |> Enum.map(fn {m, i} -> Map.put(m, "id", i) end)
    )
    |> Map.put(
      "double_jeopardy",
      json["double_jeopardy"]
      |> Enum.sort(fn a, b ->
        if a["category"] == b["category"],
          do: a["value"] < b["value"],
          else: a["category"] < b["category"]
      end)
      |> Enum.with_index(31)
      |> Enum.map(fn {m, i} -> Map.put(m, "id", i) end)
    )
  end

  defp archive_path(), do: Path.join(:code.priv_dir(:jeopardy), "jarchive")
end
