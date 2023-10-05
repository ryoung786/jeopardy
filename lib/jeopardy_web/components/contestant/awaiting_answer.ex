defmodule JeopardyWeb.Components.Contestant.AwaitingAnswer do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    assign(socket,
      buzzed?: game.buzzer == socket.assigns.name,
      buzzer: game.buzzer
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <div :if={@buzzed?}>
        <h3>You buzzed in!</h3>
        <p>Tell <%= @trebek %> your answer.</p>
      </div>
      <div :if={!@buzzed?}>
        <p><%= @buzzer %> buzzed in.</p>
        <p>Waiting for them to answer.</p>
      </div>
    </div>
    """
  end

  def handle_game_server_msg({:revealed_category, index}, socket) do
    {:ok, assign(socket, index: index)}
  end
end
