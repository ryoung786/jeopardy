defmodule Jeopardy.Games.Clue do
  use Jeopardy.Games.Schema
  import Ecto.{Changeset, Query}
  alias Jeopardy.Repo
  alias Jeopardy.Games
  alias Jeopardy.Games.{Player, Clue}

  schema "clues" do
    field :category, :string
    field :clue_text, :string
    field :answer_text, :string
    field :value, :integer, default: 0
    field :round, :string
    field :type, :string
    field :asked_status, :string, default: "unasked"
    field :wager, :integer
    field :incorrect_players, {:array, :id}, default: []
    field :correct_players, {:array, :id}, default: []
    field :replicated_at, :utc_datetime
    belongs_to :game, Jeopardy.Games.Game

    timestamps()
  end

  @doc false
  def changeset(clue, attrs) do
    clue
    |> cast(attrs, [
      :category,
      :clue_text,
      :answer_text,
      :value,
      :round,
      :type,
      :asked_status,
      :wager,
      :incorrect_players,
      :correct_players
    ])
    |> validate_required([:clue_text, :answer_text, :type, :asked_status])
  end

  def is_daily_double(clue), do: not is_nil(clue) && clue.type == "daily_double"
  def asked(clue), do: not is_nil(clue) && clue.asked_status == "asked"
  def game(clue), do: Games.get_game!(clue.game_id)

  def contestants_remaining?(clue), do: contestants_remaining?(clue, Clue.game(clue))

  def contestants_remaining?(clue, game) do
    num_contestants =
      from(p in Player, select: count(1), where: p.game_id == ^game.id and p.name != ^game.trebek)
      |> Repo.one()

    num_contestants - Enum.count(clue.incorrect_players) > 0
  end
end
