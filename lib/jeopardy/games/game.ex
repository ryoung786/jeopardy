defmodule Jeopardy.Games.Game do
  use Jeopardy.Games.Schema
  import Ecto.{Changeset, Query}

  schema "games" do
    field :code, :string, null: false, size: 4
    field :status, :string, default: "pre_jeopardy"
    field :round_status, :string
    field :trebek, :string, size: 25
    field :is_active, :boolean, default: true

    field :board_control, :string, size: 25
    field :current_clue_id, :id
    field :buzzer_player, :string, size: 25 # name of the player that has buzzed
    field :buzzer_lock_status, :string, default: "locked" # can be locked, clear, or player

    field :jarchive_game_id, :id
    field :jeopardy_round_categories, {:array, :string}, default: []
    field :double_jeopardy_round_categories, {:array, :string}, default: []
    field :final_jeopardy_category, :string
    field :air_date, :date

    has_many :players, Jeopardy.Games.Player
    has_many :clues, Jeopardy.Games.Clue

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:code, :status, :round_status, :trebek,
                   :is_active, :jarchive_game_id, :jeopardy_round_categories,
                   :double_jeopardy_round_categories, :air_date,
                    :buzzer_player, :buzzer_lock_status, :current_clue_id,
                   :final_jeopardy_category, :board_control])
    |> update_change(:code, &String.upcase/1)
    |> validate_required([:code, :status, :is_active])
    |> validate_format(:code, ~r/[A-Z]{4}/, message: "must be 4 uppercase letters")
    |> validate_length(:trebek, max: 25, message: "Keep it short! 25 letters is the max.")
  end

  def current_clue(%Jeopardy.Games.Game{} = game) do
    case game.current_clue_id do
      nil -> nil
      _ -> Jeopardy.Repo.get(Jeopardy.Games.Clue, game.current_clue_id)
    end
  end
end
