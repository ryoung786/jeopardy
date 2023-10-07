defmodule Jeopardy.GameServer do
  use GenServer, restart: :transient
  alias Jeopardy.Game
  require Logger

  defmodule State do
    defstruct ~w/code inactivity_timeout game/a
  end

  @inactivity_timeout :timer.hours(4)

  def start_link({code, timeout}) do
    GenServer.start_link(__MODULE__, {code, timeout}, name: via_tuple(code))
  end

  # CLIENT API

  def new_game_server(opts \\ []) do
    id_to_load = Keyword.get(opts, :game_id, :random)
    inactivity_timeout = Keyword.get(opts, :timeout, @inactivity_timeout)
    code = generate_code()

    case DynamicSupervisor.start_child(
           Jeopardy.GameSupervisor,
           {__MODULE__, {code, inactivity_timeout}}
         ) do
      {:ok, _pid} -> action(code, :load_game, id_to_load) && code
      {:error, {:already_started, _}} -> new_game_server(opts)
    end
  end

  @doc """
  Send an action to the game server.  Returns {:ok, game} or error tuple.
  """
  def action(code, action, data \\ nil), do: call(code, {:action, action, data})

  @doc """
  Send an action to the game server.  Returns {:ok, game} or error tuple.
  """
  def admin_action(code, action, data \\ nil), do: call(code, {:admin_action, action, data})
  def get_game(code), do: call(code, :get_game)

  # SERVER
  @impl true
  def init({code, timeout}) do
    state = %State{code: code, inactivity_timeout: timeout, game: %Game{code: code}}
    {:ok, state, state.inactivity_timeout}
  end

  @impl true
  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_call(:get_game, _from, state),
    do: {:reply, {:ok, state.game}, state, state.inactivity_timeout}

  @impl true
  def handle_call({:action, action, data}, _from, state) do
    case Jeopardy.FSM.handle_action(action, state.game, data) do
      {:ok, game} ->
        {:reply, {:ok, game}, %{state | game: game}, state.inactivity_timeout}

      {:error, reason} ->
        Logger.error("Invalid action", action: action)
        {:reply, {:error, reason}, state, state.inactivity_timeout}
    end
  end

  @impl true
  def handle_call({:admin_action, action, data}, _from, state) do
    case Jeopardy.AdminActions.handle_action(action, state.game, data) do
      {:ok, game} -> {:reply, {:ok, game}, %{state | game: game}, state.inactivity_timeout}
      {:error, reason} -> {:reply, {:error, reason}, state, state.inactivity_timeout}
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
    IO.inspect(command, label: "[xxx] action")

    case game_pid(code) do
      pid when is_pid(pid) -> GenServer.call(pid, command)
      nil -> {:error, :game_not_found}
    end
  end
end
