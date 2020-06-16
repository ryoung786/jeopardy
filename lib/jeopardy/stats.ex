defmodule Jeopardy.Stats do
  alias Jeopardy.Games
  alias Jeopardy.Games.Game
  require Logger

  def create(%Game{} = game) do
    Cachex.put!(:stats, key(game), %{}, ttl: :timer.hours(48))
    update(game)
  end

  def update(%Game{} = game) do
    with {_, stats} <- Cachex.fetch(:stats, key(game), fn _ -> %{} end) do
      new_stats =
        Games.get_just_contestants(game)
        |> Enum.reduce(%{}, fn c, acc ->
          Map.put(acc, c.id, %{
            name: c.name,
            scores: (get_in(stats, [c.id, :scores]) || []) ++ [c.score]
          })
        end)

      Cachex.update!(:stats, key(game), new_stats)
      broadcast(game)
    end
  end

  def key(%Game{} = game), do: "game:#{game.id}"

  defp broadcast(%Game{} = game) do
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, game.code, %{
      event: :stats_update,
      payload: %{game_id: game.id, game_code: game.code}
    })
  end
end
