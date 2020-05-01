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

  def buzzer(id, name) do
    Logger.info("in buzzer #{name}")
    GenServer.cast(Jeopardy.Cache, {:buzzer, id, name})
    Logger.info("after buzzer #{name}")
  end

  def clearBuzzer(id) do
    GenServer.cast(Jeopardy.Cache, {:clear_buzzer, id})
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

  @impl true
  def handle_cast({:buzzer, game_id, name}, _state) do
    game = case :ets.lookup(@table, game_id) do
      [{^game_id, v}] -> v
      _ -> nil
    end
    with %{buzzer: :clear} <- game do
      game = %{game | buzzer: name}
      Logger.info("HANDLE_CAST game: #{inspect(game)}")
      :ets.insert(@table, {game.id, game})

      # broadcast out that we got a successful buzz
      Phoenix.PubSub.broadcast(Jeopardy.PubSub, "buzz", {:buzz, name})
    end
    {:noreply, false}
  end

  @impl true
  def handle_cast({:clear_buzzer, game_id}, _state) do
    game = case :ets.lookup(@table, game_id) do
      [{^game_id, v}] -> v
      _ -> nil
    end
    game = %{game | buzzer: :clear}
    :ets.insert(@table, {game.id, game})
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, "clear", :clear)
    {:noreply, false}
  end
end
