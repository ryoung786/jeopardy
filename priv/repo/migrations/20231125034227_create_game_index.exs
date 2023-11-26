defmodule Jeopardy.Repo.Migrations.CreateGameIndex do
  use Ecto.Migration

  def change do
    execute(
      """
      CREATE VIRTUAL TABLE game_index USING fts5(
        game_id UNINDEXED,
        year,
        decade,
        season,
        difficulty,
        air_date,
        comments,
        contestant_1,
        contestant_2,
        contestant_3,
        tokenize="trigram"
      );
      INSERT INTO game_index(game_index, rank) VALUES(
        'rank',
        'bm25(10.0, 1.0, 10.0, 0.0, 5.0, 1.0, 8.0, 8.0, 8.0)'
      );
      """,
      """
      DROP TABLE game_index;
      """
    )
  end
end
