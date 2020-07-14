defmodule Jeopardy.FSM do
  require Logger

  @callback handle(atom, any, map) :: {:ok, map}
  @callback on_enter(map) :: map

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
