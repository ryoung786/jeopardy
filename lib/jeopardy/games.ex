defmodule Jeopardy.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false

  require Logger
  alias Jeopardy.Games.{Game, Player, Clue}
  alias Jeopardy.Repo
  alias Jeopardy.GameState

  def get_game!(id),
    do:
      from(g in Game,
        where: g.id == ^id,
        left_join: p in assoc(g, :players),
        left_join: c in assoc(g, :clues),
        preload: [players: p, clues: c]
      )
      |> Repo.one()

  def get_by_code(code) do
    Game
    |> where([g], g.code == ^code)
    |> where([g], g.is_active == true)
    # |> preload([_], [:players])
    |> Repo.one()
  end

  def create() do
    %Game{}
    |> Game.changeset(%{code: generate_game_code()})
    |> Repo.insert()
  end

  def create_from_random_jarchive() do
    with {:ok, game} <- create(),
         game when game != :error <- Jeopardy.JArchive.load_into_game(game) do
      {:ok, game}
    else
      {:error, error} -> {:error, error}
      :error -> {:error, "something went wrong"}
    end
  end

  def create_from_draft_game(%Jeopardy.Drafts.Game{} = draft_game) do
    with {:ok, game} <- create() do
      Jeopardy.Drafts.load_into_game(draft_game, game)
    else
      {:error, error} -> {:error, error}
    end
  end

  def assign_trebek(%Game{} = game, name) do
    q =
      from g in Game,
        where: g.id == ^game.id and is_nil(g.trebek),
        select: g.id

    case q |> Repo.update_all_ts(set: [trebek: name]) do
      {0, _} ->
        {:failed, nil}

      {1, [_id]} ->
        GameState.update_round_status(game.code, "selecting_trebek", "introducing_roles")
    end
  end

  def assign_board_control(%Game{} = game, :random) do
    # in the jeopardy round, we pick who goes first randomly
    # in the double jeopardy round, it goes to the player with the lowest score
    contestants = get_just_contestants(game)

    player_name =
      case game.status do
        "jeopardy" ->
          Enum.random(contestants) |> Map.get(:name)

        "double_jeopardy" ->
          Enum.sort_by(contestants, & &1.score, :asc) |> Enum.map(& &1.name) |> List.first()
      end

    Game.changeset(game, %{board_control: player_name}) |> Repo.update()
  end

  def assign_board_control(%Game{} = game, player_name) do
    Game.changeset(game, %{board_control: player_name}) |> Repo.update()
  end

  def get_just_contestants(%Game{} = game) do
    from(p in Player,
      where: p.game_id == ^game.id and p.name != ^game.trebek,
      order_by: [asc: p.id]
    )
    |> Repo.all()
  end

  def get_all_players(%Game{} = game) do
    from(p in Player, where: p.game_id == ^game.id)
    |> Repo.all()
  end

  def get_player(%Game{} = game, name) do
    from(p in Player, where: p.game_id == ^game.id and p.name == ^name) |> Repo.one()
  end

  _ = """
  Returns a random 4-letter code
  """

  defp generate_game_code() do
    chars = "ABCDEFGHJKMNPQRSTUVWXYZ" |> String.split("", trim: true)

    code =
      Enum.reduce(1..4, [], fn _i, acc ->
        [Enum.random(chars) | acc]
      end)
      |> Enum.join("")

    if existing_active_games_with_code?(code), do: generate_game_code(), else: code
  end

  defp existing_active_games_with_code?(code) do
    from(g in Game, select: count(1), where: g.code == ^code, where: g.is_active == true)
    |> Repo.one() > 0
  end

  def can_buzz?(%Game{} = _game, nil), do: false

  def can_buzz?(%Game{} = game, %Player{} = player) do
    from(g in Game,
      where: g.id == ^game.id,
      where: g.buzzer_lock_status == "clear",
      where: is_nil(g.buzzer_player),
      join: c in Clue,
      on: c.id == g.current_clue_id,
      on: ^player.id not in c.incorrect_players,
      select: g
    )
    |> Repo.one()
    |> is_nil()
    |> Kernel.not()
  end

  def daily_double_buzzer(%Game{} = game) do
    Game.changeset(game, %{buzzer_player: game.board_control}) |> Repo.update()
  end

  def clear_buzzer(%Game{} = game) do
    from(g in Game, where: g.id == ^game.id)
    |> Repo.update_all_ts(set: [buzzer_player: nil, buzzer_lock_status: "clear"])

    get_game!(game.id)
  end

  def lock_buzzer(%Game{} = game) do
    from(g in Game, where: g.id == ^game.id)
    |> Repo.update_all_ts(set: [buzzer_player: nil, buzzer_lock_status: "locked"])

    get_game!(game.id)
  end

  def players(%Game{} = game), do: Repo.all(Ecto.assoc(game, :players))

  def clues_by_category(%Game{} = game, round) when round in [:jeopardy, :double_jeopardy] do
    clues =
      from(c in Clue,
        where: c.game_id == ^game.id,
        where: c.round == ^Atom.to_string(round),
        order_by: [asc: c.value]
      )
      |> Repo.all()

    category_names =
      if round == :jeopardy,
        do: game.jeopardy_round_categories,
        else: game.double_jeopardy_round_categories

    Enum.map(category_names, fn category ->
      [category: category, clues: clues |> Enum.filter(fn clue -> clue.category == category end)]
    end)
  end

  def set_current_clue(%Game{} = game, clue_id) do
    Game.changeset(game, %{current_clue_id: clue_id}) |> Repo.update()
  end

  def no_answer(%Game{} = game) do
    q = from g in Game, where: g.id == ^game.id, where: g.buzzer_lock_status == "clear"

    case q |> Repo.update_all_ts(set: [buzzer_player: nil, buzzer_lock_status: "locked"]) do
      {1, _} ->
        from(c in Clue, select: c, where: c.id == ^game.current_clue_id)
        |> Repo.update_all_ts(set: [asked_status: "asked"])

        Jeopardy.GameState.update_round_status(game.code, "awaiting_buzzer", "revealing_answer")

      response ->
        Logger.error("Couldn't update no_answer, error: #{inspect(response)}")
    end
  end

  def set_up_final_jeopardy(%Game{} = game) do
    final_jeopardy_clue_id =
      from(c in Clue,
        select: c.id,
        where: c.game_id == ^game.id,
        where: c.round == "final_jeopardy"
      )
      |> Repo.one()

    set_current_clue(game, final_jeopardy_clue_id)
  end

  def contestants_yet_to_be_updated(%Game{} = game) do
    from(p in Player,
      where: p.game_id == ^game.id,
      where: p.name != ^game.trebek,
      where: not p.final_jeopardy_score_updated,
      order_by: [asc: p.score]
    )
    |> Repo.all()
  end
end
