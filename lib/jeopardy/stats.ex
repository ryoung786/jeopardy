defmodule Jeopardy.Stats do
  alias Jeopardy.Games
  alias Jeopardy.Games.Game
  require Logger

  def create(%Game{} = game) do
    Cachex.put!(:stats, key(game), %{}, ttl: :timer.hours(48))
  end

  def update(%Game{} = game) do
    with {_, stats} <- Cachex.fetch(:stats, key(game), fn _ -> %{} end) do
      stats =
        Games.get_just_contestants(game)
        |> Enum.reduce(%{}, fn c, acc ->
          Map.put(acc, c.id, Map.get(stats, c.id, []) ++ [c.score])
        end)

      Cachex.update!(:stats, key(game), stats)
    end
  end

  def dump() do
    {:ok, keys} = Cachex.keys(:stats)

    keys
    |> Enum.each(fn k -> Logger.info("XXX k,v: #{inspect(Cachex.get(:stats, k))}") end)
  end

  defp key(game), do: "game:#{game.id}"
end
