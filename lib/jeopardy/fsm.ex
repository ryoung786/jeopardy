defmodule Jeopardy.FSM do
  def broadcast(topic, data) do
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, topic, data)
  end

  def module_from_game(%Jeopardy.Games.Game{} = game) do
    {a, b} = {Macro.camelize(game.status), Macro.camelize(game.round_status)}
    a = if game.status == "double_jeopardy", do: "Jeopardy", else: a
    String.to_existing_atom("Elixir.Jeopardy.FSM.#{a}.#{b}")
  end
end
