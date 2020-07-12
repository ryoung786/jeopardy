defmodule Jeopardy.FSM do
  alias Jeopardy.Games.Player
  require Logger

  @callback handle(atom, any, map) :: {:ok, map}
  @callback on_enter(map) :: map

  def set_early_buzz_penalty(player_id) do
    Cachex.put!(:stats, "player:#{player_id}:early_buzz", DateTime.utc_now())

    Phoenix.PubSub.broadcast(
      Jeopardy.PubSub,
      "player:#{player_id}",
      {:early_buzz, :locked}
    )

    Task.start(fn ->
      :timer.sleep(Application.get_env(:jeopardy, :early_buzz_penalty))

      if not Player.buzzer_locked_by_early_buzz?(player_id) do
        Phoenix.PubSub.broadcast(
          Jeopardy.PubSub,
          "player:#{player_id}",
          {:early_buzz, :unlocked}
        )
      end
    end)
  end

  def clear_early_buzzer_penalties(players) do
    time = DateTime.add(DateTime.utc_now(), -1_000_000_000, :second)

    Enum.each(players, fn {id, _p} ->
      Cachex.put!(:stats, "player:#{id}:early_buzz", time)
    end)
  end

  defmacro __using__([]) do
    quote do
      import Ecto.Query, warn: false
      import Jeopardy.GameEngine.State, only: [retrieve_state: 1]
      alias Jeopardy.Repo
      alias Jeopardy.GameEngine.State
      require Logger

      @behaviour Jeopardy.FSM

      def on_enter(state), do: state

      defoverridable(on_enter: 1)
    end
  end
end
