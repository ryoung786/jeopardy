defmodule JeopardyWeb.Components.Tv.SelectingClue do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.PlayerRemoved

  def assign_init(socket, game) do
    assign(socket,
      categories: game.board.categories,
      clues:
        Map.new(game.board.clues, fn {category, clues} ->
          {category, Map.keys(clues)}
        end)
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.board categories={@game.categories} clues={@game.board} />
      </.tv>
    </div>
    """
  end

  def handle_game_server_msg(%PlayerRemoved{name: name}, socket), do: handle_tv_player_removed(name, socket)
  def handle_game_server_msg(_, socket), do: {:ok, socket}
end
