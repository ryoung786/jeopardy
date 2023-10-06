defmodule JeopardyWeb.Components.Trebek.GradingFinalJeopardyAnswers do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer

  def assign_init(socket, game) do
    {:ok,
     assign(socket,
       answer: game.clue.answer,
       contestants: Map.new(game.contestants, &{&1.name, &1.final_jeopardy_answer})
     )}
  end

  def render(assigns) do
    ~H"""
    <div>
      <ul>
        <li :for={{_name, answer} <- Enum.shuffle(@contestants)}>
          <%= answer %>
        </li>
      </ul>
      <.button class="btn btn-primary" phx-target={@myself} phx-click="submit">
        Submit
      </.button>
    </div>
    """
  end

  def handle_event("submit", _params, socket) do
    GameServer.action(socket.assigns.code, {:submitted_grades})
    {:noreply, socket}
  end
end
