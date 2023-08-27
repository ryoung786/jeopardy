defmodule Jeopardy.FSM.SelectingTrebek do
  @moduledoc """
  :selecting_trebek -> :introducing_roles
  """

  @behaviour Jeopardy.FSM.Handler

  alias Jeopardy.Game

  @impl true
  def valid_actions(), do: ~w/select_trebek/a

  @impl true
  def handle_action(:select_trebek, %Game{} = game, name), do: select_trebek(game, name)

  def select_trebek(%Game{} = game, name) do
    if name in game.players,
      do: {:ok, %{game | trebek: name, status: :introducing_roles}},
      else: {:error, :player_does_not_exist}
  end
end
