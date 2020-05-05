defmodule Mix.Tasks.ParseJArchiveHtmlDir do
  use Mix.Task

  import Ecto.Query, warn: false
  alias Jeopardy.Repo
  alias Jeopardy.JArchive.{Game, Clue}

  @shortdoc "Sends a greeting to us from Hello Phoenix"

  @moduledoc """
    This is where we would put any long form documentation or doctests.
  """

  def run(_args) do
    Mix.Task.run "app.start"

    clean_db()

    path_to_html_files = "/Users/ryany/dev/jeopardy-parser/j-archive"
    {:ok, files} = File.ls(path_to_html_files)
    files
    |> Enum.take(10)
    |> Enum.each(fn f ->
      Mix.shell.info("f: #{inspect(Path.absname(f))}")
      {:ok, fp} = File.read(Path.join(path_to_html_files, f))

      # parse(fp)
    end)

    {:ok, f} = File.read("../../jeopardy-parser/j-archive/4527.html")
    parse(f)
  end

  def clean_db() do
    Ecto.Adapters.SQL.query!(Repo, "delete FROM jarchive.clues")
    Ecto.Adapters.SQL.query!(Repo, "delete FROM jarchive.games")
  end

  def parse(f) do
    {:ok, html} = Floki.parse_document(f)
    show_id =
      Floki.find(html, "title") |> Floki.text
      |> String.replace(~r/^.*Show .([0-9]+),.*$/, "\\1") |> String.to_integer
    {:ok, air_date} = Floki.find(html, "title") |> Floki.text |> String.replace(~r/^.*aired (.*)$/, "\\1") |> Date.from_iso8601

    clues = (Floki.find(html, "#jeopardy_round") |> parse_round(:jeopardy)) ++
      (Floki.find(html, "#double_jeopardy_round") |> parse_round(:double_jeopardy))
    # Floki.find(html, "#double_jeopardy_round") |> parse_round(:final_jeopardy)

    {_, game} = %Game{
      id: show_id,
      air_date: air_date,
      jeopardy_round_categories: categories_by_round(:jeopardy, html),
      double_jeopardy_round_categories: categories_by_round(:double_jeopardy, html),
      final_jeopardy_category: "placeholder"
    } |> Repo.insert()

    Enum.each(clues, fn clue ->
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
end
