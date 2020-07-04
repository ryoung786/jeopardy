defmodule Jeopardy.GameEngine.State do
  alias __MODULE__
  alias Jeopardy.Games.Game
  alias Jeopardy.Repo
  import Ecto.Query
  require Logger

  defstruct(
    game: nil,
    trebek: nil,
    clues: nil,
    contestants: nil,
    current_clue: nil
  )

  def retrieve_state(game_id) when is_number(game_id) do
    game =
      from(g in Game,
        where: g.id == ^game_id,
        left_join: p in assoc(g, :players),
        left_join: c in assoc(g, :clues),
        preload: [players: p, clues: c]
      )
      |> Repo.one()

    retrieve_state(game)
  end

  def retrieve_state(%Game{} = game) do
    clues = game.clues |> list_to_id_map()

    contestants =
      game.players
      |> filter_out_trebek(game.trebek)
      |> list_to_id_map()

    %State{
      game: game,
      trebek: get_trebek(game.players, game.trebek),
      clues: clues,
      contestants: contestants,
      current_clue: clues[game.current_clue_id]
    }
  end

  def update_round(state, round) do
    from(g in Game, where: g.id == ^state.game.id)
    |> Repo.update_all_ts(set: [round_status: round])

    retrieve_state(state.game.id)
  end

  defp filter_out_trebek(players, trebek_name),
    do: Enum.filter(players, &(&1.name != trebek_name))

  defp list_to_id_map(lst),
    do: Enum.reduce(lst, %{}, fn x, acc -> Map.put(acc, x.id, x) end)

  defp get_trebek(players, trebek_name),
    do: Enum.filter(players, &(&1.name == trebek_name)) |> List.first()
end
