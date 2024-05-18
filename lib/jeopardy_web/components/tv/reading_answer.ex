defmodule JeopardyWeb.Components.Tv.ReadingAnswer do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.PlayerRemoved

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants}>
        <.clue category={@game.clue.category}><%= @game.clue.answer %></.clue>
      </.tv>
    </div>
    """
  end

  def handle_game_server_msg(%PlayerRemoved{name: name}, socket), do: handle_tv_player_removed(name, socket)
  def handle_game_server_msg(_, socket), do: {:ok, socket}
end
