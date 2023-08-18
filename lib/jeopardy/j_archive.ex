defmodule Jeopardy.JArchive do
  @req Req.new(base_url: "https://j-archive.com")

  def load_game(:random) do
    file_name =
      Application.app_dir(:jeopardy, "priv/jarchive")
      |> File.ls!()
      |> Enum.shuffle()
      |> Enum.drop_while(fn filename -> !String.ends_with?(filename, ".json") end)
      |> List.first()

    if file_name != nil,
      do: Path.basename(file_name, ".json") |> load_game(),
      else: {:error, "No games exist"}
  end

  def load_game(game_id) do
    path = Application.app_dir(:jeopardy, "priv/jarchive")

    with {:ok, file} <- File.read(Path.join(path, "#{game_id}.json")) do
      {:ok, Jason.decode!(file, keys: :atoms)}
    else
      _ -> {:error, "Game does not exist"}
    end
  end

  def download_and_parse_game(game_id, opts \\ [force_download: false]) do
    if game_already_downloaded?(game_id) && !opts[:force_download] do
      :ok
    else
      path = Application.app_dir(:jeopardy, "priv/jarchive")

      json =
        Req.get!(@req, url: "showgame.php", params: [game_id: game_id]).body
        |> Floki.parse_document!()
        |> Jeopardy.JArchive.Parser.parse_game()
        |> Jason.encode!()

      File.write(Path.join(path, "#{game_id}.json"), json)
    end
  end

  def download_season(season_id, opts \\ [force_download: false]) do
    if season_fully_downloaded?(season_id) && !opts[:force_download] do
      :ok
    else
      game_ids =
        Req.get!(@req, url: "showseason.php", params: [season: season_id]).body
        |> Floki.parse_document!()
        |> game_ids_from_season_html()

      Task.async_stream(game_ids, &download_and_parse_game/1, max_concurrency: 5)
      |> Enum.to_list()

      if season_finished_airing?(game_ids) do
        path = Application.app_dir(:jeopardy, "priv/jarchive/completed_seasons")
        File.touch(Path.join(path, "#{season_id}"))
      end
    end
  end

  def game_ids_from_season_html(html) do
    html
    |> Floki.attribute("#content table td:first-child a", "href")
    |> Enum.map(fn href ->
      [_, id] = Regex.run(~r/showgame.php\?game_id=([0-9]+)/, href)
      id
    end)
  end

  def season_fully_downloaded?(season_id) do
    "#{season_id}" in fully_downloaded_season_ids()
  end

  def fully_downloaded_season_ids() do
    # Once we are sure all of a season's games have been downloaded, parsed, and stored
    # in a json file, an empty file with the `season_id` as its name is placed in the
    # priv/jarchive/completed_seasons directory.
    # In this way, we can avoid repeatedly downloading seasons we already have

    Application.app_dir(:jeopardy, "priv/jarchive/completed_seasons")
    |> File.ls!()
  end

  def game_already_downloaded?(game_id) do
    path = Application.app_dir(:jeopardy, "priv/jarchive")
    File.exists?(Path.join([path, "#{game_id}.json"]))
  end

  def season_finished_airing?(season_game_ids) do
    two_months_ago = Date.utc_today() |> Date.add(-60)
    most_recent_game = List.first(season_game_ids) |> load_game()
    Date.before?(most_recent_game.air_date, two_months_ago)
  end
end
