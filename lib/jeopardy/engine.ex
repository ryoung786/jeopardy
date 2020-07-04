defmodule Jeopardy.Engine do
  use GenServer, restart: :transient
  require Logger
  @timeout 3 * 24 * 60 * 60 * 1_000

  def start_link(options) do
    Logger.warn("[xxx] options #{inspect(options)}")
    GenServer.start_link(__MODULE__, %{}, options)
  end

  @impl true
  def init(state) do
    {:ok, state, @timeout}
  end

  @impl true
  def handle_cast(%{event: _event, data: _data} = event, state) do
    # handle the event in the correct module
    module = module_from_game(state)
    {new_state, payload_to_broadcast} = module.handle(event)
    # if the FSM has entered a new state, run that on_enter function
    new_state = run_onenter_if_necessary(state, new_state)
    # broadcast the new game status to all subscribers
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, new_state.game.id, payload_to_broadcast)
    {:noreply, state, @timeout}
  end

  defp module_from_game(%{game: game}) do
    {a, b} = {Macro.camelize(game.status), Macro.camelize(game.round_status)}
    a = if game.status == "double_jeopardy", do: "Jeopardy", else: a
    String.to_existing_atom("Elixir.Jeopardy.Engine.#{a}.#{b}")
  end

  defp run_onenter_if_necessary(old_state, new_state) do
    if did_game_change_rounds?(old_state, new_state),
      do: new_state,
      else: module_from_game(new_state).init(new_state)
  end

  defp did_game_change_rounds?(old, new) do
    old.game.status == new.game.status && old.game.round_status == new.game.round_status
  end

  defmacro __using__([]) do
    quote do
      def on_enter(state), do: state
    end
  end
end
