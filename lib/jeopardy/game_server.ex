defmodule Jeopardy.GameServer do
  use GenServer, restart: :transient
  alias Jeopardy.Game
  require Logger

  defmodule State do
    defstruct ~w/code last_interaction game/a
  end

  def start_link(code), do: GenServer.start_link(__MODULE__, code, name: via_tuple(code))

  @spec new_game_server(pos_integer() | :random) :: String.t()
  def new_game_server(jarchive_game_id) do
    code = new_game_server()
    {:ok, _game} = action(code, :load_game, jarchive_game_id)
    code
  end

  def new_game_server() do
    code = generate_code()

    case DynamicSupervisor.start_child(Jeopardy.GameSupervisor, {__MODULE__, code}) do
      {:ok, _pid} -> code
      {:error, {:already_started, _}} -> new_game_server()
    end
  end

  def delete_game_server(code) do
    case game_pid(code) do
      pid when is_pid(pid) ->
        DynamicSupervisor.terminate_child(Jeopardy.GameSupervisor, pid)

      nil ->
        :ok
    end
  end

  def action(code, action, data), do: call(code, {:action, action, data})
  def get_game(code), do: call(code, :get_game)

  # SERVER
  @impl true
  def init(code) do
    {:ok, %State{code: code, game: %Game{code: code}, last_interaction: DateTime.utc_now()}}
  end

  @impl true
  def handle_call(:get_game, _from, state), do: {:reply, {:ok, state.game}, state}

  @impl true
  def handle_call({:action, action, data}, _from, state) do
    state = %{state | last_interaction: DateTime.utc_now()}

    case Jeopardy.FSM.handle_action(action, state.game, data) do
      {:ok, game} -> {:reply, {:ok, game}, %{state | game: game}}
      {:error, reason} -> {:reply, {:error, reason}, state}
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
