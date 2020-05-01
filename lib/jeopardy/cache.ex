defmodule Jeopardy.Cache do
  use GenServer
  require Logger

  @table :games

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(nil) do
    :ets.new(@table, [:named_table])
    :ets.insert(@table, {1, %{id: 1, buzzer: :clear}})
    {:ok, nil}
  end

  def find(id) do
    GenServer.call(Jeopardy.Cache, {:find, id})
  end

  def save(game) do
    GenServer.call(Jeopardy.Cache, {:save, game})
  end


  @impl true
  def handle_call({:find, id}, _from, _state) do
    result = case :ets.lookup(@table, id) do
      [{^id, v}] -> v
      _ -> nil
    end
    {:reply, result, nil}
  end

  @impl true
  def handle_call({:save, game}, _from, _state) do
    :ets.insert(@table, {game.id, game})
    {:reply, game, nil}
  end
end
