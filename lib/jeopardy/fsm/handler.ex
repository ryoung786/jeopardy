defmodule Jeopardy.FSM.Handler do
  @callback valid_actions() :: [atom]
  @callback handle_action(atom, %Jeopardy.Game{}, term) ::
              {:ok, %Jeopardy.Game{}} | {:error, term}
end
