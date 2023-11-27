defmodule Jeopardy.JArchive.Parser do
  @moduledoc false
  def parse_game(html, season_id) do
    %{
      jeopardy: Enum.map(1..6, &parse_round_category(html, :jeopardy, &1)),
      double_jeopardy: Enum.map(1..6, &parse_round_category(html, :double_jeopardy, &1)),
      final_jeopardy: %{
        category: html |> Floki.find("#final_jeopardy_round .category_name") |> Floki.text(),
        clue: html |> Floki.find("#clue_FJ") |> Floki.text(),
        answer: html |> Floki.find("#clue_FJ_r .correct_response") |> Floki.text()
      },
      categories: %{
        jeopardy: html |> Floki.find("#jeopardy_round .category_name") |> Enum.map(&Floki.text/1),
        double_jeopardy: html |> Floki.find("#double_jeopardy_round .category_name") |> Enum.map(&Floki.text/1),
        final_jeopardy: html |> Floki.find("#final_jeopardy_round .category_name") |> Floki.text()
      },
      air_date: parse_air_date(html),
      contestants: html |> Floki.find("#contestants .contestants a") |> Enum.map(&Floki.text/1),
      comments: html |> Floki.find("#game_comments") |> Floki.text(),
      season: season_id
    }
  end

  def parse_round_category(entire_game_html, round, category_idx) do
    {round_selector, round_abbrev, dollar_multiplier} =
      case round do
        :jeopardy -> {"#jeopardy_round", "J", 2}
        :double_jeopardy -> {"#double_jeopardy_round", "DJ", 4}
      end

    html = Floki.find(entire_game_html, round_selector)

    category_name =
      html |> Floki.find(".category_name") |> Enum.at(category_idx - 1) |> Floki.text()

    clues =
      Enum.map(1..5, fn clue_idx ->
        cell_html =
          Floki.find(
            html,
            ".round > tr:nth-of-type(#{clue_idx + 1}) > td:nth-of-type(#{category_idx})"
          )

        dd_selector = ".clue_value_daily_double"
        clue_selector = "#clue_#{round_abbrev}_#{category_idx}_#{clue_idx}"
        answer_selector = "#clue_#{round_abbrev}_#{category_idx}_#{clue_idx}_r .correct_response"

        %{
          clue: cell_html |> Floki.find(clue_selector) |> Floki.text(),
          answer: cell_html |> Floki.find(answer_selector) |> Floki.text(),
          value: dollar_multiplier * 100 * clue_idx,
          daily_double?: Floki.find(cell_html, dd_selector) != [],
          category: category_name
        }
      end)

    %{category: category_name, clues: clues}
  end

  def parse_air_date(html) do
    title = html |> Floki.find("head title") |> Floki.text()

    # The 2 Trebek pilot episodes were never aired, but they do have a
    # tape date, so let's use that instead
    with [_, _, date_str] <- Regex.run(~r/(aired|taped) (\d\d\d\d-\d\d?-\d\d?)$/, title),
         {:ok, air_date} <- Date.from_iso8601(date_str) do
      air_date
    else
      _ -> nil
    end
  end
end
