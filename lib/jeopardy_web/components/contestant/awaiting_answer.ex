defmodule JeopardyWeb.Components.Contestant.AwaitingAnswer do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, _game) do
    assign(socket, buzzed?: socket.assigns.game.buzzer == socket.assigns.name)
  end

  def render(assigns) do
    ~H"""
    <div>
      <div :if={@buzzed?}>
        <h3>You buzzed in!</h3>
        <p>Tell <%= @game.trebek %> your answer.</p>
      </div>
      <div :if={!@buzzed?}>
        <p><%= @game.buzzer %> buzzed in.</p>
        <p>Waiting for them to answer.</p>
      </div>
    </div>
    """
  end

  def handle_game_server_msg({:revealed_category, index}, socket) do
    {:ok, assign(socket, index: index)}
  end
end
