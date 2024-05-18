defmodule JeopardyWeb.Components.Tv.AwaitingDailyDoubleWager do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.PlayerRemoved

  def render(assigns) do
    ~H"""
    <div>
      <.tv contestants={@game.contestants} buzzer={@game.board_control}>
        <.clue category={@game.clue.category} daily_double_background?={@game.clue.daily_double?}>
          DAILY DOUBLE
        </.clue>
        />
      </.tv>
    </div>
    """
  end

  def handle_game_server_msg(%PlayerRemoved{name: name}, socket), do: handle_tv_player_removed(name, socket)
  def handle_game_server_msg(_, socket), do: {:ok, socket}
end
