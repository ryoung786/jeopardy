defmodule Mix.Tasks.ParseJArchiveHtmlDir do
  use Mix.Task

  import Ecto.Query, warn: false
  alias Jeopardy.Repo
  alias Jeopardy.JArchive.{Game, Clue}

  @shortdoc "Sends a greeting to us from Hello Phoenix"
  @archive_path "/Users/ryany/dev/jeopardy-parser/j-archive"

  @moduledoc """
    This is where we would put any long form documentation or doctests.
  """

  def run(args) do
    Mix.Task.run "app.start"
    clean_db()

    get_files(args) |> process_files()
  end

  def get_files([_|_] = ids), do: Enum.map(ids, fn id -> "#{id}.html" end)
  def get_files([]) do
    {:ok, files} = File.ls(@archive_path)
    files
  end
  def process_files(files) do
    Enum.each(files, fn file ->
      Mix.shell.info("processing: #{inspect(file)}")
      with {:ok, f} <- File.read(Path.join(@archive_path, file)) do
        parse(f)
      else
        _ -> Mix.shell.error("Couldn't find #{file}")
      end
    end)
  end

  def clean_db() do
    Ecto.Adapters.SQL.query!(Repo, "delete FROM jarchive.clues")
    Ecto.Adapters.SQL.query!(Repo, "delete FROM jarchive.games")
  end

  def parse(f) do
    {:ok, html} = Floki.parse_document(f)
    # show_id =
    #   Floki.find(html, "title") |> Floki.text
    #   |> String.replace(~r/^.*Show .([0-9]+),.*$/, "\\1") |> String.to_integer
    air_date = parse_air_date(html)

    clues = (Floki.find(html, "#jeopardy_round") |> parse_round(:jeopardy))
    ++ (Floki.find(html, "#double_jeopardy_round") |> parse_round(:double_jeopardy))

    # some archive games don't have a final jeopardy round
    # in that case, we'll still store what we can, but the game's final_jeopardy_category will be nil
    # With that set, we'll be able to filter out bad games downstream
    final_jeopardy_clue = parse_final_jeopardy_clue(html)

    {_, game} = %Game{
      air_date: air_date,
      jeopardy_round_categories: categories_by_round(:jeopardy, html),
      double_jeopardy_round_categories: categories_by_round(:double_jeopardy, html),
      final_jeopardy_category: final_jeopardy_clue.category
    } |> Repo.insert()

    [final_jeopardy_clue | clues]
    |> Enum.reject(fn clue -> is_nil(clue.category) end)
    |> Enum.each(fn clue ->
      Ecto.build_assoc(game, :clues, clue) |> Repo.insert()
    end)
  end

  defp categories_by_round(round, html) when round == :jeopardy, do: categories_by_round("#jeopardy_round", html)
  defp categories_by_round(round, html) when round == :double_jeopardy, do: categories_by_round("#double_jeopardy_round", html)
  defp categories_by_round(round, html) when round == :final_jeopardy, do: categories_by_round("#final_jeopardy_round", html)
  defp categories_by_round(round, html) do
    Floki.find(html, "#{round} .category_name") |> Enum.map( &Floki.text/1)
  end



  def parse_round(html, round) do
    categories = Floki.find(html, ".category_name") |> Enum.map( &Floki.text/1)

    Floki.find(html, "td.clue")
    |> Enum.with_index # [{clue, idx}, ...]
    |> Enum.map( fn {clue, i} ->
      parse_clue(clue, i, categories, round)
    end)
  end

  def parse_clue(clue, idx, categories, round) do
    category = Enum.at(categories, rem(idx, 6))
    round_num = case round do
                  :jeopardy -> 1
                  :double_jeopardy -> 2
                  :final_jeopardy -> 0
                end
    value = 100 * round_num * (div(idx, 6) + 1)

    question = clue |> Floki.find(".clue_text") |> Floki.text
    if question == "" do
      %Clue{ value: value, round: Atom.to_string(round), category: category }
    else
      answer = clue |> Floki.attribute("div", "onmouseover") |> List.first |> String.replace(~r/^.*correct_response">(.*)<\/em.*$/, "\\1")
      is_daily_double = Floki.find(clue, ".clue_value_daily_double") |> Enum.count > 0
      type = if is_daily_double, do: "daily_double", else: "standard"

      %Clue{
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
    question = Floki.find(clue, "td.clue_text") |> Floki.text
    category = Floki.find(clue, "td.category_name") |> Floki.text

    case category do
      "" -> %Clue{}
      _ ->
        answer = clue
        |> Floki.attribute("div", "onmouseover") |> List.first
        |> String.replace(~r/^.*em class.*correct_response.*">(.+)<\/em>.*$/, "\\1")

        %Clue{
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
    |> Floki.text
    |> String.replace(~r/^.*([0-9]{4}.[0-9]{2}.[0-9]{2}).*$/, "\\1")
    |> Date.from_iso8601 do
      {:ok, air_date} -> air_date
      _ -> nil
    end
  end
end
