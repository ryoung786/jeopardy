defmodule JeopardyWeb.Components.Contestant.RecappingRound do
  use JeopardyWeb.FSMComponent

  def render(assigns) do
    ~H"""
    <div>
      <.instructions>Round complete.</.instructions>
    </div>
    """
  end

  def handle_game_server_msg({:revealed_category, index}, socket) do
    {:ok, assign(socket, index: index)}
  end
end
