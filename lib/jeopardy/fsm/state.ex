defmodule Jeopardy.FSM.State do
  @callback valid_actions() :: [atom]
  @callback handle_action(atom, %Jeopardy.Game{}, term) ::
              {:ok, %Jeopardy.Game{}} | {:error, term}
  @callback initial_data(%Jeopardy.Game{}) :: any()

  defmacro __using__(_opts) do
    quote do
      @behaviour Jeopardy.FSM.State

      alias Jeopardy.FSM

      def initial_data(_), do: %{}
      defoverridable initial_data: 1

      defp update_data(data) do
        %FSM{state: __MODULE__, data: data}
      end
    end
  end
end
