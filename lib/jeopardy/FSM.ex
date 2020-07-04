defmodule Jeopardy.FSM do
  require Logger

  defmacro __using__([]) do
    quote do
      import Ecto.Query, warn: false
      import Jeopardy.GameEngine.State, only: [retrieve_state: 1]
      alias Jeopardy.Repo
      alias Jeopardy.GameEngine.State

      def on_enter(state), do: state
    end
  end
end
