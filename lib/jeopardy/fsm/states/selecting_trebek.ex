defmodule Jeopardy.FSM.SelectingTrebek do
  @moduledoc """
  :selecting_trebek -> :introducing_roles
  """

  use Jeopardy.FSM.State

  alias Jeopardy.Contestant
  alias Jeopardy.FSM
  alias Jeopardy.FSM.IntroducingRoles
  alias Jeopardy.Game

  @impl true
  def valid_actions, do: ~w/select_trebek/a

  @impl true
  def handle_action(:select_trebek, %Game{} = game, name), do: select_trebek(game, name)

  def select_trebek(%Game{} = game, trebek) do
    if trebek in Map.keys(game.players) do
      rest = game.players |> Map.delete(trebek) |> Map.values()
      contestants = Map.new(rest, &{&1.name, Contestant.new(&1)})

      FSM.broadcast(game, %FSM.Messages.TrebekSelected{trebek: trebek})

      {:ok,
       game
       |> Map.put(:trebek, trebek)
       |> Map.put(:contestants, contestants)
       |> FSM.to_state(IntroducingRoles)}
    else
      {:error, :player_does_not_exist}
    end
  end
end
