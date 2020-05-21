defmodule Mix.Tasks.ParseToJson do
  use Mix.Task

  @shortdoc "Parse jarchive html files and write to json files"
  @archive_path "/Users/ryany/dev/jeopardy-parser/j-archive"
  @out_path Path.join(:code.priv_dir(:jeopardy), "jarchive")

  def run(args) do
    Mix.Task.run("app.start")

    get_files(args) |> process_files()
  end

  def get_files([_ | _] = ids), do: Enum.map(ids, fn id -> "#{id}.html" end)

  def get_files([]) do
    {:ok, files} = File.ls(@archive_path)
    files
  end

  def process_files(files) do
    Enum.with_index(files)
    |> Enum.each(fn {file, i} ->
      if rem(i, 100) == 0, do: Mix.shell().info("processed #{i} files")

      with {:ok, f} <- File.read(Path.join(@archive_path, file)) do
        game = parse(f, i)
        File.write(Path.join(@out_path, "#{i}.json"), Jason.encode!(game))
      else
        _ -> Mix.shell().error("Couldn't find #{file}")
      end
    end)
  end

  def parse(f, id) do
    {:ok, html} = Floki.parse_document(f)
    final_jeopardy_clue = parse_final_jeopardy_clue(html)

    %{
      id: id,
      air_date: parse_air_date(html),
      jeopardy_round_categories: categories_by_round(:jeopardy, html),
      double_jeopardy_round_categories: categories_by_round(:double_jeopardy, html),
      final_jeopardy_category: final_jeopardy_clue[:category],
      jeopardy: parse_round(Floki.find(html, "#jeopardy_round"), :jeopardy),
      double_jeopardy: parse_round(Floki.find(html, "#double_jeopardy_round"), :double_jeopardy),
      final_jeopardy: final_jeopardy_clue
    }
  end

  defp categories_by_round(round, html) when round == :jeopardy,
    do: categories_by_round("#jeopardy_round", html)

  defp categories_by_round(round, html) when round == :double_jeopardy,
    do: categories_by_round("#double_jeopardy_round", html)

  defp categories_by_round(round, html) do
    Floki.find(html, "#{round} .category_name") |> Enum.map(&Floki.text/1)
  end

  def parse_round(html, round) do
    categories = Floki.find(html, ".category_name") |> Enum.map(&Floki.text/1)

    Floki.find(html, "td.clue")
    # [{clue, idx}, ...]
    |> Enum.with_index()
    |> Enum.map(fn {clue, i} ->
      parse_clue(clue, i, categories, round)
    end)
  end

  def parse_clue(clue, idx, categories, round) do
    category = Enum.at(categories, rem(idx, 6))

    round_num =
      case round do
        :jeopardy -> 1
        :double_jeopardy -> 2
        :final_jeopardy -> 0
      end

    value = 100 * round_num * (div(idx, 6) + 1)

    question = clue |> Floki.find(".clue_text") |> Floki.text()

    if question == "" do
      %{value: value, round: Atom.to_string(round), category: category}
    else
      answer =
        clue
        |> Floki.attribute("div", "onmouseover")
        |> List.first()
        |> String.replace(~r/^.*correct_response">(.*)<\/em.*$/, "\\1")

      is_daily_double = Floki.find(clue, ".clue_value_daily_double") |> Enum.count() > 0
      type = if is_daily_double, do: "daily_double", else: "standard"

      %{
        clue_text: question,
        answer_text: answer,
        value: value,
        round: Atom.to_string(round),
        type: type,
        category: category
      }
    end
  end

  def parse_final_jeopardy_clue(html) do
    clue = Floki.find(html, "table.final_round")
    question = Floki.find(clue, "td.clue_text") |> Floki.text()
    category = Floki.find(clue, "td.category_name") |> Floki.text()

    case category do
      "" ->
        %{}

      _ ->
        answer =
          clue
          |> Floki.attribute("div", "onmouseover")
          |> List.first()
          |> String.replace(~r/^.*em class.*correct_response.*">(.+)<\/em>.*$/, "\\1")

        %{
          clue_text: question,
          answer_text: answer,
          round: "final_jeopardy",
          type: "final_jeopardy",
          category: category
        }
    end
  end

  def parse_air_date(html) do
    case Floki.find(html, "title")
         |> Floki.text()
         |> String.replace(~r/^.*([0-9]{4}.[0-9]{2}.[0-9]{2}).*$/, "\\1")
         |> Date.from_iso8601() do
      {:ok, air_date} -> air_date
      _ -> nil
    end
  end
end
