defmodule Jeopardy.GameEngine do
  alias Jeopardy.GameEngine.State
  require Logger

  def event(event, game_id),
    do: event(event, nil, game_id)

  def event(event, data, game_id) do
    state = State.retrieve_state(game_id)
    module = module_from_game(state)

    with {:ok, new_state} <- module.handle(event, data, state) do
      new_state = run_onenter_if_necessary(state, new_state)

      unless state == new_state,
        do:
          Phoenix.PubSub.broadcast(
            Jeopardy.PubSub,
            "game:#{game_id}",
            new_state
          )

      :ok
    else
      {:error, msg} -> {:error, msg}
    end
  end

  defp module_from_game(%{game: game}) do
    {a, b} = {Macro.camelize(game.status), Macro.camelize(game.round_status)}
    a = if game.status == "double_jeopardy", do: "Jeopardy", else: a
    String.to_existing_atom("Elixir.Jeopardy.FSM.#{a}.#{b}")
  end

  defp run_onenter_if_necessary(old_state, new_state) do
    if did_game_change_rounds?(old_state, new_state),
      do: new_state,
      else: module_from_game(new_state).on_enter(new_state)
  end

  defp did_game_change_rounds?(old, new) do
    old.game.status == new.game.status &&
      old.game.round_status == new.game.round_status
  end

  defmacro __using__([]) do
    quote do
      def on_enter(state), do: state
    end
  end
end
