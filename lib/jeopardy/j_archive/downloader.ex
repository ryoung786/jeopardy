defmodule Jeopardy.JArchive.Downloader do
  @moduledoc false

  alias Jeopardy.JArchive
  alias Jeopardy.JArchive.GameIndex
  alias Jeopardy.Repo

  require Logger

  @req Req.new(base_url: "https://j-archive.com")

  @spec download_all_seasons() :: :ok
  def download_all_seasons do
    html = Req.get!(@req, url: "listseasons.php").body

    fully_downloaded_season_ids =
      :jeopardy
      |> Application.app_dir("priv/jarchive/completed_seasons")
      |> File.ls!()

    html
    |> Floki.parse_document!()
    |> Floki.attribute("#content a", "href")
    |> Enum.map(fn "showseason.php?season=" <> season_id -> season_id end)
    |> Enum.reject(fn season_id -> season_id in fully_downloaded_season_ids end)
    |> Enum.each(&download_season/1)
  end

  def download_season(season_id) do
    html = Floki.parse_document!(Req.get!(@req, url: "showseason.php", params: [season: season_id]).body)

    game_ids =
      html
      |> Floki.attribute("#content table td:first-child a", "href")
      |> Enum.map(fn href ->
        [_, id] = Regex.run(~r/showgame.php\?game_id=([0-9]+)/, href)
        id
      end)

    game_ids
    |> Task.async_stream(
      &download_and_parse_game(&1, season_id),
      max_concurrency: 5
    )
    |> Enum.to_list()

    # if we think the season is finished airing, add it to the completed_seasons file

    two_months_ago = Date.add(Date.utc_today(), -60)
    {:ok, most_recent_game} = game_ids |> List.first() |> Jeopardy.JArchive.load_game()
    season_finished_airing? = Date.before?(most_recent_game.air_date, two_months_ago)

    if season_finished_airing? do
      File.touch(Path.join(JArchive.completed_seasons_path(), "#{season_id}"))
    end
  end

  def download_and_parse_game(game_id, season_id) do
    if File.exists?(Path.join(JArchive.path(), "#{game_id}.json")) do
      Logger.info("Skipping download, game was cached", season_id: season_id, game_id: game_id)
    else
      Logger.info("Downloading game", season_id: season_id, game_id: game_id)

      json =
        Req.get!(@req, url: "showgame.php", params: [game_id: game_id]).body
        |> Floki.parse_document!()
        |> Jeopardy.JArchive.Parser.parse_game(season_id)

      File.write(Path.join(JArchive.path(), "#{game_id}.json"), Jason.encode!(json))
      game_id |> GameIndex.from_json(json) |> Repo.insert()
    end
  end
end
