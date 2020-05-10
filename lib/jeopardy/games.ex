defmodule Jeopardy.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false

  alias Jeopardy.Games
  alias Jeopardy.Games.{Game, Player, Clue}
  alias Jeopardy.Repo
  alias Jeopardy.JArchive
  alias Jeopardy.GameState

  def get_game!(id), do: Repo.get!(Game |> preload([_], [:players]), id)

  def get_by_code(code) do
    Game
    |> where([g], g.code == ^code)
    |> where([g], g.is_active == true)
    |> preload([_], [:players])
    |> Repo.one
  end

  def create() do
    %Game{}
    |> Game.changeset(%{code: generate_game_code()})
    |> Repo.insert()
  end

  def start(code, player_names) do
    game = get_by_code(code) |> JArchive.load_into_game()
    player_names |> Enum.each(fn name -> add_player(game, name) end)
    GameState.update_round_status(code, "awaiting_start", "selecting_trebek")
  end

  def assign_trebek(%Game{code: code} = game, name) do
    case (from g in Game, where: g.id == ^game.id and is_nil(g.trebek), select: g.id)
    |> Repo.update_all_ts(set: [trebek: name]) do
      {0, _} -> {:failed, nil}
      {1, [_id]} ->
        # Phoenix.PubSub.broadcast(Jeopardy.PubSub, code, {:trebek_assigned, name})
        GameState.update_round_status(code, "selecting_trebek", "introducing_roles")
    end
  end

  def assign_board_control(%Game{} = game, :random) do
    # in the jeopardy round, we pick who goes first randomly
    # in the double jeopardy round, it goes to the player with the lowest score
    contestants = get_just_contestants(game)
    player_name = case game.status do
      "jeopardy" -> Enum.random(contestants) |> Map.get(:name)
      "double_jeopardy" -> Enum.sort_by(contestants, & &1.score, :desc) |> Enum.map(& &1.name) |> List.first
    end
    Game.changeset(game, %{board_control: player_name}) |> Repo.update()
  end

  def assign_board_control(%Game{} = game, player_name) do
    Game.changeset(game, %{board_control: player_name}) |> Repo.update()
  end

  def get_just_contestants(%Game{} = game) do
    from(p in Player, where: p.game_id == ^game.id and p.name != ^game.trebek) |> Repo.all
  end

  def get_player(%Game{} = game, name) do
    from(p in Player, where: p.game_id == ^game.id and p.name == ^name) |> Repo.one
  end

  _ = """
  Returns a random 4-letter code
  """
  defp generate_game_code() do
    chars = "ABCDEFGHJKMNPQRSTUVWXYZ" |> String.split("", trim: true)

    code = Enum.reduce((1..4), [], fn (_i, acc) ->
      [Enum.random(chars) | acc]
    end) |> Enum.join("")

    if existing_active_games_with_code?(code), do: generate_game_code(), else: code
  end

  defp existing_active_games_with_code?(code) do
    (from g in Game, select: count(1), where: g.code == ^code, where: g.is_active == true)
    |> Repo.one > 0
  end

  def can_buzz?(%Game{} = game, %Player{} = player) do
    (from g in Game,
      where: g.id == ^game.id,
      where: g.buzzer_lock_status == "clear",
      where: is_nil(g.buzzer_player),
      join: c in Clue, on: c.id == g.current_clue_id, on: ^player.id not in c.incorrect_players,
      select: g) |> Repo.one() |> is_nil() |> Kernel.not()
  end

  def player_buzzer(%Game{} = game, name) do
    # [game, clue] = (from g in Game, where: g.id == 12, where: g.buzzer_lock_status == "clear", where: is_nil(g.buzzer_player), join: c in Clue, on: c.id == g.current_clue_id, select: [g, c]) |> Repo.one
    player = get_player(game, name)
    q = (from g in Game,
      where: g.id == ^game.id,
      where: g.buzzer_lock_status == "clear",
      where: is_nil(g.buzzer_player),
      join: c in Clue, on: c.id == g.current_clue_id, on: ^player.id not in c.incorrect_players,
      select: g.id)

    # q = (from g in Game,
    #   where: g.id == ^game.id,
    #   where: g.buzzer_lock_status == "clear",
    #   where: is_nil(g.buzzer_player),
    #   select: g.id)
    case Repo.update_all_ts(q, set: [buzzer_player: name, buzzer_lock_status: "player"]) do
      {0, _} -> {:failed, nil}
      {1, [id]} ->
      # Phoenix.PubSub.broadcast(Jeopardy.PubSub, game.code, {:buzz, name})
      # reset clue timer
        # start contestant timer
        {:ok, get_game!(id)}
    end
  end
  def clear_buzzer(%Game{} = game) do
    (from g in Game, where: g.id == ^game.id)
    |> Repo.update_all_ts(set: [buzzer_player: nil, buzzer_lock_status: "clear"])
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, game.code, :clear)
    get_game!(game.id)
  end
  def lock_buzzer(%Game{} = game) do
    (from g in Game, where: g.id == ^game.id)
    |> Repo.update_all_ts(set: [buzzer_player: nil, buzzer_lock_status: "locked"])
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, game.code, :locked)
    get_game!(game.id)
  end

  def players(%Game{} = game), do: Repo.all Ecto.assoc(game, :players)

  def add_player(%Game{} = game, name) do
    Ecto.build_assoc(game, :players, %{name: name})
    |> Repo.insert()
  end

  def clues_by_category(%Game{} = game, round) when round in [:jeopardy, :double_jeopardy] do
    clues = from(c in Clue,
      where: c.game_id == ^game.id,
      where: c.round == ^Atom.to_string(round),
      order_by: [asc: c.value])
      |> Repo.all
    category_names = if round == :jeopardy, do: game.jeopardy_round_categories, else: game.double_jeopardy_round_categories
    Enum.map(category_names, fn category ->
      [category: category,
       clues: clues |> Enum.filter(fn clue -> clue.category == category end)]
    end)
  end

  def set_current_clue(%Game{} = game, clue_id) do
    Game.changeset(game, %{current_clue_id: clue_id}) |> Repo.update()
  end

  def correct_answer(%Game{} = game) do
    player_id = from(
      p in Player, select: p.id,
      where: p.name == ^game.buzzer_player, where: p.game_id == ^game.id
    ) |> Repo.one

    # record player correctly answered clue and update clue's status
    {_, [clue|_]} = from(c in Clue, select: c, where: c.id == ^game.current_clue_id)
    |> Repo.update_all_ts(push: [correct_players: player_id], set: [asked_status: "asked"]) # TODO: will need to move this to when question is revealed, not when it's answered

    # increase score of buzzer player by current clue value
    amount = if Clue.is_daily_double(clue), do: clue.wager, else: clue.value
    from(p in Player, select: p, where: p.id == ^player_id)
    |> Repo.update_all_ts(inc: [score: amount], push: [correct_answers: clue.id])

    game
  end

  def incorrect_answer(%Game{} = game) do
    player_id = from(
      p in Player, select: p.id,
      where: p.name == ^game.buzzer_player, where: p.game_id == ^game.id
    ) |> Repo.one

    # record player incorrectly answered clue and update clue's status
    {_, [clue|_]} = from(c in Clue, select: c, where: c.id == ^game.current_clue_id)
    |> Repo.update_all_ts(push: [incorrect_players: player_id], set: [asked_status: "asked"])

    # increase score of buzzer player by current clue value
    amount = if Clue.is_daily_double(clue), do: clue.wager, else: clue.value
    from(p in Player, select: p, where: p.id == ^player_id)
    |> Repo.update_all_ts(inc: [score: -1 * amount], push: [incorrect_answers: clue.id])

    if Clue.is_daily_double(clue) do
      Games.lock_buzzer(game)
      GameState.update_round_status(game.code, "answering_daily_double", "revealing_answer")
    else
      case Clue.contestants_remaining?(clue) do
        true ->
          Games.clear_buzzer(game)
          GameState.update_round_status(game.code, "answering_clue", "awaiting_buzzer")
        _ ->
          Games.lock_buzzer(game)
          GameState.update_round_status(game.code, "answering_clue", "revealing_answer")
      end
    end

    game
  end
end
