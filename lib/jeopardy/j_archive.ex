defmodule Jeopardy.JArchive do
  @req Req.new(base_url: "https://j-archive.com")

  def download_and_parse_game(game_id) do
    Req.get!(@req, url: "showgame.php", params: [game_id: game_id]).body
    |> Floki.parse_document!()
    |> Jeopardy.JArchive.Parser.parse_game()
  end
end
