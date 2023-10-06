defmodule JeopardyWeb.Components.Trebek.ReadingFinalJeopardyClue do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.GameServer
  alias Jeopardy.Timers

  @timer 60_000

  def assign_init(socket, game) do
    time_remaining = Timers.time_remaining(game.fsm.data[:expires_at])

    {:ok,
     assign(socket,
       category: game.clue.category,
       clue: game.clue.clue,
       time_remaining: time_remaining,
       contestants: Map.new(game.contestants, &{&1.name, &1.final_jeopardy_answer}),
       finished_reading?: time_remaining != nil
     )}
  end

  def render(assigns) do
    ~H"""
    <div>
      <div :if={@finished_reading?}>
        <ul>
          <li :for={{name, answer} <- @contestants}>
            <.status_icon answered?={answer != nil} /> <%= name %>
          </li>
        </ul>
        <.pie_timer timer={@timer} time_remaining={@time_remaining} />
      </div>

      <div :if={not @finished_reading?}>
        <h3><%= @category %></h3>
        <h3><%= @clue %></h3>

        <p>Read the clue, then click the button to start the timer.</p>
        <.button class="btn btn-primary" phx-target={@myself} phx-click="finished-reading">
          Start Timer
        </.button>
      </div>
    </div>
    """
  end

  defp status_icon(%{wagered?: true} = assigns), do: ~H|<.icon name="hero-clock" />|
  defp status_icon(assigns), do: ~H|<.icon name="hero-check-circle" />|

  def handle_event("finished-reading", _params, socket) do
    GameServer.action(socket.assigns.code, {:timer_started})
    {:noreply, assign(socket, finished_reading?: true, time_remaining: @timer)}
  end
end
