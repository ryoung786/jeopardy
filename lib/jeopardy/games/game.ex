defmodule Jeopardy.Games.Game do
  use Jeopardy.Games.Schema
  import Ecto.Changeset

  schema "games" do
    field :buzzer, :string
    field :code, :string, null: false, size: 4
    field :status, :string, default: "awaiting_start"
    field :round_status, :string
    field :trebek, :string, size: 25
    field :is_active, :boolean, default: true

    field :jarchive_game_id, :id
    field :jeopardy_round_categories, {:array, :string}
    field :double_jeopardy_round_categories, {:array, :string}
    field :final_jeopardy_category, :string
    field :air_date, :date

    has_many :players, Jeopardy.Games.Player
    has_many :clues, Jeopardy.Games.Clue

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:code, :status, :buzzer, :round_status, :trebek,
                   :is_active, :jarchive_game_id, :jeopardy_round_categories,
                   :double_jeopardy_round_categories, :air_date,
                   :final_jeopardy_category])
    |> update_change(:code, &String.upcase/1)
    |> validate_required([:code, :status, :is_active])
    |> validate_format(:code, ~r/[A-Z]{4}/, message: "must be 4 uppercase letters")
    |> validate_length(:trebek, max: 25, message: "Keep it short! 25 letters is the max.")
  end
end
