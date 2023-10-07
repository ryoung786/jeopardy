defmodule Jeopardy.FSM do
  use TypedStruct

  typedstruct do
    field :state, module()
    field :data, any()
  end

  alias Jeopardy.Game

  def handle_action(action, game, data) do
    if action in game.fsm.state.valid_actions(),
      do: game.fsm.state.handle_action(action, game, data),
      else: {:error, :invalid_action}
  end

  @spec to_state(%Game{}, module()) :: %Game{}
  def to_state(%Game{} = game, module) do
    game
    |> Map.put(:fsm, %__MODULE__{
      state: module,
      data: module.initial_data(game)
    })
    |> broadcast({:status_changed, module})
  end

  def broadcast(%Jeopardy.Game{code: code} = game, message) do
    broadcast(code, message)
    game
  end

  def broadcast(code, message) do
    IO.inspect(message, label: "[xxx] broadcast")
    Phoenix.PubSub.broadcast(Jeopardy.PubSub, "games:#{code}", message)
  end

  def to_component(state, :tv) do
    alias = state |> to_string() |> String.split(".") |> List.last()
    "Elixir.JeopardyWeb.Components.Tv.#{alias}" |> String.to_existing_atom()
  end

  def to_component(state, :trebek) do
    alias = state |> to_string() |> String.split(".") |> List.last()
    "Elixir.JeopardyWeb.Components.Trebek.#{alias}" |> String.to_existing_atom()
  end

  def to_component(state, _) do
    alias = state |> to_string() |> String.split(".") |> List.last()
    "Elixir.JeopardyWeb.Components.Contestant.#{alias}" |> String.to_existing_atom()
  end
end
