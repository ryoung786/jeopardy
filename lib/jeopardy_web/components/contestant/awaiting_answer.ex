defmodule JeopardyWeb.Components.Contestant.AwaitingAnswer do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, _game) do
    assign(socket, buzzed?: socket.assigns.game.buzzer == socket.assigns.name)
  end

  def render(assigns) do
    ~H"""
    <div>
      <.instructions>
        <span :if={@buzzed?}>
          You buzzed in!  Tell <%= @game.trebek %> your answer.
        </span>
        <span :if={not @buzzed?}>
          <%= @game.buzzer %> buzzed in.<br />Waiting for them to answer.
        </span>
      </.instructions>
    </div>
    """
  end

  def handle_game_server_msg({:revealed_category, index}, socket) do
    {:ok, assign(socket, index: index)}
  end
end
