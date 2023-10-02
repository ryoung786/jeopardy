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
    broadcast(game, {:status_changed, module})

    Map.put(game, :fsm, %__MODULE__{
      state: module,
      data: module.initial_data(game)
    })
  end

  def broadcast(%Jeopardy.Game{code: code}, message), do: broadcast(code, message)

  def broadcast(code, message) do
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
