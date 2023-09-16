defmodule Jeopardy.FSM.Handler do
  @callback valid_actions() :: [atom]
  @callback handle_action(atom, %Jeopardy.Game{}, term) ::
              {:ok, %Jeopardy.Game{}} | {:error, term}
  @callback initial_state(%Jeopardy.Game{}) :: any()

  defmacro __using__(_) do
    quote do
      @behaviour Jeopardy.FSM.Handler
      def initial_state(_), do: %{}
      defoverridable initial_state: 1
    end
  end
end
