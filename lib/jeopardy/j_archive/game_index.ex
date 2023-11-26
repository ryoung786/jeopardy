defmodule Jeopardy.JArchive.GameIndex do
  @moduledoc false
  use TypedEctoSchema

  import Ecto.Changeset
  import Ecto.Query

  alias Jeopardy.JArchive
  alias Jeopardy.Repo

  @primary_key {:id, :id, autogenerate: true, source: :rowid}
  typed_schema "game_index" do
    field :game_id, :integer
    field :year, :integer
    field :decade, :integer
    field :season, :string
    field :difficulty, :string
    field :air_date, :date
    field :comments, :string
    field :contestant_1, :string
    field :contestant_2, :string
    field :contestant_3, :string
    field :rank, :float, virtual: true
  end

  defp changeset(attrs) do
    cast(%__MODULE__{}, attrs, [
      :game_id,
      :year,
      :decade,
      :season,
      :difficulty,
      :air_date,
      :comments,
      :contestant_1,
      :contestant_2,
      :contestant_3
    ])
  end

  defp difficulty(nil = _comments), do: "normal"

  defp difficulty(comments) do
    re_very_hard = ~r/(greatest of all time)|(masters)|(battle of the decades)|(all-star)|(all star)|(ibm challenge)/i
    re_hard = ~r/(tournament of champions)|(professor)/i
    re_easy = ~r/kids|celebrity|teen/i

    cond do
      Regex.match?(re_very_hard, comments) -> "very_hard"
      Regex.match?(re_hard, comments) -> "hard"
      Regex.match?(re_easy, comments) -> "easy"
      :else -> "normal"
    end
  end

  def from_json(game_id, json) do
    {:ok, game} =
      json
      |> Jeopardy.JArchive.RecordedGame.changeset()
      |> Ecto.Changeset.apply_action(:load)

    from_recorded_game(game_id, game)
  end

  def from_recorded_game(game_id) do
    {:ok, game} = JArchive.load_game(game_id)
    from_recorded_game(game_id, game)
  end

  def from_recorded_game(game_id, game) do
    attrs = %{
      game_id: game_id,
      year: game.air_date.year,
      decade: 10 * div(game.air_date.year, 10),
      season: game.season,
      difficulty: difficulty(game.comments),
      air_date: game.air_date,
      comments: game.comments,
      contestant_1: Enum.at(game.contestants, 0),
      contestant_2: Enum.at(game.contestants, 1),
      contestant_3: Enum.at(game.contestants, 2)
    }

    changeset(attrs)
  end

  def search(query_string, opts \\ []) do
    # wrap in double quotes to force phrases, otherwise characters like hyphens
    # and periods are interpreted as column delimiters
    query_string = "\"#{query_string}\""

    q = from(game in __MODULE__, where: fragment("game_index MATCH ?", ^query_string))
    q = if opts[:decades], do: where(q, [g], g.decade in ^opts[:decades]), else: q
    q = if opts[:difficulty], do: where(q, [g], g.difficulty in ^opts[:difficulty]), else: q

    q
    |> select([:air_date, :rank])
    |> order_by(asc: :rank)
    |> Repo.all()
  end
end
