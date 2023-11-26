defmodule Jeopardy.JArchive do
  @moduledoc """
  Finding and loading a specific game from the archive.
  """

  alias Jeopardy.JArchive.Downloader
  alias Jeopardy.JArchive.GameIndex
  alias Jeopardy.Repo

  @jarchive_path Application.app_dir(:jeopardy, "priv/jarchive")
  @completed_seasons_path Application.app_dir(:jeopardy, "priv/jarchive/completed_seasons")

  def path, do: Application.get_env(:jeopardy, :jarchive_dir, @jarchive_path)
  def completed_seasons_path, do: @completed_seasons_path

  @spec load_game(any) :: {:ok, Jeopardy.JArchive.RecordedGame.t()} | {:error, any}
  def load_game(:random) do
    file_name =
      path()
      |> File.ls!()
      |> Enum.shuffle()
      |> Enum.drop_while(fn filename -> !String.ends_with?(filename, ".json") end)
      |> List.first()

    if file_name != nil,
      do: file_name |> Path.basename(".json") |> load_game(),
      else: {:error, "No games exist"}
  end

  def load_game(game_id) do
    with {:ok, file} <- File.read(Path.join(path(), "#{game_id}.json")),
         {:ok, json} <- Jason.decode(file) do
      json
      |> Jeopardy.JArchive.RecordedGame.changeset()
      |> Ecto.Changeset.apply_action(:load)
    else
      _ -> {:error, "Game does not exist"}
    end
  end

  def choose_game(opts \\ []) do
    _difficulty_filter = Keyword.get(opts, :difficulty, :any)
    _decade_filter = Keyword.get(opts, :decade, :any)
  end

  def reset_archive do
    File.rm_rf!(path())
    File.mkdir_p(completed_seasons_path())
    Repo.delete_all(GameIndex)

    Downloader.download_all_seasons()
  end
end
