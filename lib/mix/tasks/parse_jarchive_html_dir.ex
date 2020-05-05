defmodule Mix.Tasks.ParseJArchiveHtmlDir do
  use Mix.Task

  import Ecto.Query, warn: false
  alias Jeopardy.Repo
  alias Jeopardy.JArchive.{Show}

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

      parse(fp)
    end)

    # {:ok, f} = File.read("../../jeopardy-parser/j-archive/4527.html")
    # parse(f)
  end

  def clean_db() do
    Ecto.Adapters.SQL.query!(Repo, "delete FROM jarchive.clues")
    Ecto.Adapters.SQL.query!(Repo, "delete FROM jarchive.categories")
    Ecto.Adapters.SQL.query!(Repo, "delete FROM jarchive.boards")
    Ecto.Adapters.SQL.query!(Repo, "delete FROM jarchive.shows")
  end

  def parse(f) do

    {:ok, html} = Floki.parse_document(f)
    show_id =
      Floki.find(html, "title") |> Floki.text
      |> String.replace(~r/^.*Show .([0-9]+),.*$/, "\\1") |> String.to_integer
    {:ok, air_date} = Floki.find(html, "title") |> Floki.text |> String.replace(~r/^.*aired (.*)$/, "\\1") |> Date.from_iso8601
    {_, show} = %Show{id: show_id, air_date: air_date} |> Repo.insert()
    {_, board} = Ecto.build_assoc(show, :board, %{}) |> Repo.insert()
    round_one_html = Floki.find(html, "#jeopardy_round")
    parse_round(1, round_one_html, board)
    round_two_html = Floki.find(html, "#double_jeopardy_round")
    parse_round(2, round_two_html, board)
  end

  def parse_round(round_num, html, board) do
    category_names = Floki.find(html, ".category_name") |> Enum.map( &Floki.text/1)

    categories = category_names |> Enum.map( fn cname ->
      {_, category} = Ecto.build_assoc(board, :categories, %{name: cname}) |> Repo.insert()
      category
    end)

    clues =
      Floki.find(html, "td.clue") |> Enum.with_index # [{clue, idx}, ...]
      |> Enum.map( fn {clue, i} -> parse_clue(clue, i, categories, round_num) end)
    Enum.each(clues, fn clue -> Repo.insert(clue) end)

    {categories, clues}
  end

  def parse_clue(clue, idx, categories, round_num) do
    category = Enum.at(categories, rem(idx, 6))
    category_name = category.name
    value = 100 * round_num * (div(idx, 6) + 1)

    question = clue |> Floki.find(".clue_text") |> Floki.text
    if question == "" do
      Ecto.build_assoc(category, :clues, %{value: value, category_name: category.name})
    else
      answer = clue |> Floki.attribute("div", "onmouseover") |> List.first |> String.replace(~r/^.*correct_response">(.*)<\/em.*$/, "\\1")

      type = cond do
        Floki.find(clue, ".clue_value_daily_double") |> Enum.count > 0 -> "daily_double"
        round_num == 1 || round_num == 2 -> "standard"
        true -> "final_jeopardy"
      end

      Ecto.build_assoc(category, :clues,
        %{
          clue_text: question,
          answer_text: answer,
          type: type,
          value: value,
          category_name: category_name
        })
    end
  end
end
