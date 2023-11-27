defmodule Jeopardy.JArchive.Downloader do
  @moduledoc false

  alias Jeopardy.JArchive
  alias Jeopardy.JArchive.GameIndex
  alias Jeopardy.Repo

  require Logger

  @req Req.new(base_url: "https://j-archive.com")

  @spec download_all_seasons() :: :ok
  def download_all_seasons do
    Req.get!(@req, url: "listseasons.php").body
    |> season_ids_from_listseasons_html()
    |> Enum.each(&download_season/1)
  end

  @spec download_season(any, [{:force_download, boolean}]) :: :ok | {:error, File.posix()}
  def download_season(season_id, opts \\ [force_download: false]) do
    if season_fully_downloaded?(season_id) && !opts[:force_download] do
      :ok
    else
      game_ids =
        Req.get!(@req, url: "showseason.php", params: [season: season_id]).body
        |> Floki.parse_document!()
        |> game_ids_from_season_html()

      game_ids
      |> Task.async_stream(&download_and_parse_game(&1, season_id, force_download: opts[:force_download]),
        max_concurrency: 5
      )
      |> Enum.to_list()

      if season_finished_airing?(game_ids) do
        File.touch(Path.join(JArchive.completed_seasons_path(), "#{season_id}"))
      end
    end
  end

  @spec download_and_parse_game(any, [{:force_download, boolean}]) :: :ok | {:error, File.posix()}
  def download_and_parse_game(game_id, season_id, opts \\ [force_download: false]) do
    if game_already_downloaded?(game_id) && !opts[:force_download] do
      Logger.info("Skipping download, game was cached", game_id: game_id)
    else
      Logger.info("Downloading game", game_id: game_id)

      json =
        Req.get!(@req, url: "showgame.php", params: [game_id: game_id]).body
        |> Floki.parse_document!()
        |> Jeopardy.JArchive.Parser.parse_game(season_id)

      File.write(Path.join(JArchive.path(), "#{game_id}.json"), Jason.encode!(json))
      game_id |> GameIndex.from_json(json) |> Repo.insert()
    end
  end

  defp season_ids_from_listseasons_html(html) do
    html
    |> Floki.parse_document!()
    |> Floki.attribute("#content a", "href")
    |> Enum.map(fn "showseason.php?season=" <> season_id -> season_id end)
  end

  @spec game_ids_from_season_html(Floki.html_tree()) :: [String.t()]
  defp game_ids_from_season_html(html) do
    html
    |> Floki.attribute("#content table td:first-child a", "href")
    |> Enum.map(fn href ->
      [_, id] = Regex.run(~r/showgame.php\?game_id=([0-9]+)/, href)
      id
    end)
  end

  @spec season_fully_downloaded?(any) :: boolean
  defp season_fully_downloaded?(season_id) do
    "#{season_id}" in fully_downloaded_season_ids()
  end

  @spec fully_downloaded_season_ids() :: [String.t()]
  defp fully_downloaded_season_ids do
    # Once we are sure all of a season's games have been downloaded, parsed, and stored
    # in a json file, an empty file with the `season_id` as its name is placed in the
    # priv/jarchive/completed_seasons directory.
    # In this way, we can avoid repeatedly downloading seasons we already have

    :jeopardy
    |> Application.app_dir("priv/jarchive/completed_seasons")
    |> File.ls!()
  end

  @spec game_already_downloaded?(any) :: boolean
  defp game_already_downloaded?(game_id) do
    File.exists?(Path.join(JArchive.path(), "#{game_id}.json"))
  end

  @spec season_finished_airing?(list(any)) :: boolean
  defp season_finished_airing?(season_game_ids) do
    two_months_ago = Date.add(Date.utc_today(), -60)
    {:ok, most_recent_game} = season_game_ids |> List.first() |> Jeopardy.JArchive.load_game()
    Date.before?(most_recent_game.air_date, two_months_ago)
  end
end
