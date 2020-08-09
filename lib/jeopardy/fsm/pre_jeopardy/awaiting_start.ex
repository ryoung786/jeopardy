defmodule Jeopardy.FSM.PreJeopardy.AwaitingStart do
  use Jeopardy.FSM

  def handle(:start_game, _data, %{game: _game} = state) do
    if state.game.players |> Enum.count() >= 2,
      do: {:ok, State.update_round(state, "selecting_trebek")},
      else: {:error, :not_enough_players}
  end

  def handle(:add_player, %{player_name: name}, state) do
    with false <- is_name_taken?(state.game.players, name),
         {:ok, _} <-
           Ecto.build_assoc(state.game, :players, %{name: name})
           |> Jeopardy.Repo.insert() do
      {:ok, retrieve_state(state.game.id)}
    else
      true -> {:error, :name_taken}
    end
  end

  def handle(:remove_player, player_id, state) do
    Jeopardy.Repo.delete(%Jeopardy.Games.Player{id: player_id})
    {:ok, retrieve_state(state.game.id)}
  end

  defp is_name_taken?(players, name),
    do: players |> Enum.any?(fn p -> p.name == name end)
end
