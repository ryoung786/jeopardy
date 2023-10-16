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
    if trebek in game.players do
      rest = List.delete(game.players, trebek)
      contestants = Map.new(rest, &{&1, %Contestant{name: &1}})

      FSM.broadcast(game, {:trebek_selected, trebek})

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
