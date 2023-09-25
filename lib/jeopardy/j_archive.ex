defmodule Jeopardy.JArchive do
  @spec load_game(any) :: {:ok, Jeopardy.JArchive.RecordedGame.t()} | {:error, any}
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
    default_path = Application.app_dir(:jeopardy, "priv/jarchive")
    path = Application.get_env(:jeopardy, :jarchive_dir, default_path)

    with {:ok, file} <- File.read(Path.join(path, "#{game_id}.json")),
         {:ok, json} <- Jason.decode(file) do
      json
      |> Jeopardy.JArchive.RecordedGame.changeset()
      |> Ecto.Changeset.apply_action(:load)
    else
      _ -> {:error, "Game does not exist"}
    end
  end
end
