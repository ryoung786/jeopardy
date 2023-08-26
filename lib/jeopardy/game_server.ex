defmodule Jeopardy.GameServer do
  use GenServer, restart: :transient
  alias Jeopardy.Game
  require Logger

  defmodule State do
    defstruct ~w/code status last_interaction players game/a
  end

  def start_link(code), do: GenServer.start_link(__MODULE__, code, name: via_tuple(code))

  def new_game_server() do
    code = generate_code()

    case start_server_process(code) do
      {:ok, _pid} -> code
      {:error, {:already_started, _}} -> new_game_server()
    end
  end

  defp start_server_process(code) do
    DynamicSupervisor.start_child(Jeopardy.GameSupervisor, {__MODULE__, code})
  end

  def delete_game_server(code) do
    case game_pid(code) do
      pid when is_pid(pid) ->
        DynamicSupervisor.terminate_child(Jeopardy.GameSupervisor, pid)

      nil ->
        :ok
    end
  end

  def add_player(code, name), do: call(code, {:add_player, name})
  def remove_player(code, name), do: call(code, {:remove_player, name})

  # SERVER
  @impl true
  def init(code) do
    {:ok, %State{code: code, game: %Game{}, last_interaction: DateTime.utc_now()}}
  end

  @impl true
  def handle_call({:add_player, name}, _from, state) do
    case Game.add_player(state.game, name) do
      {:ok, %Game{} = game} ->
        # broadcast(state.code, state.game, :player_added, name)
        {:reply, {:ok, game.players}, %{state | game: game}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call({:remove_player, name}, _from, state) do
    case Game.remove_player(state.game, name) do
      {:ok, %Game{} = game} ->
        # broadcast(state.code, state.game, :player_removed, name)
        {:reply, {:ok, game.players}, %{state | game: game}}

      {:error, _reason} ->
        {:reply, {:ok, state.game.players}, state}
    end
  end

  # HELPERS

  def game_pid(code), do: code |> via_tuple() |> GenServer.whereis()

  defp via_tuple(code), do: {:via, Registry, {Jeopardy.GameRegistry, code}}

  defp generate_code() do
    "ABCDEFGHJKMNPQRSTUVWXYZ"
    |> String.graphemes()
    |> Enum.shuffle()
    |> Enum.take(4)
    |> Enum.join()
  end

  defp call(code, command) do
    case game_pid(code) do
      pid when is_pid(pid) -> GenServer.call(pid, command)
      nil -> {:error, :game_not_found}
    end
  end
end
