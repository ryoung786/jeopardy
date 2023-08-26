defmodule Jeopardy.Game do
  alias __MODULE__
  defstruct status: :awaiting_players, players: [], board: %{}, trebek: nil, contestants: %{}

  @spec add_player(%Game{}, String.t()) :: {:ok, %Game{}} | {:error, atom}
  def add_player(%Game{} = game, name) do
    with :ok <- ensure_status(game, :awaiting_players) do
      if name not in game.players,
        do: {:ok, %{game | players: [name | game.players]}},
        else: {:error, :name_not_unique}
    end
  end

  @spec remove_player(%Game{}, String.t()) :: {:ok, %Game{}} | {:error, atom}
  def remove_player(%Game{} = game, name) do
    with :ok <- ensure_status(game, :awaiting_players) do
      if name in game.players,
        do: {:ok, %{game | players: List.delete(game.players, name)}},
        else: {:error, :player_does_not_exist}
    end
  end

  defp ensure_status(%Game{} = game, status) do
    if game.status == status, do: :ok, else: {:error, :invalid_status}
  end
end
