defmodule JeopardyWeb.Components.Trebek.ReadingFinalJeopardyClue do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.Timers

  def assign_init(socket, game) do
    time_remaining = Timers.time_remaining(game.fsm.data[:expires_at])

    {:ok,
     assign(socket,
       category: game.clue.category,
       clue: game.clue.clue,
       time_remaining: time_remaining,
       contestants: Map.new(game.contestants, &{&1.name, &1.final_jeopardy_answer}),
       finished_reading: time_remaining != nil
     )}
  end

  def render(assigns) do
    ~H"""
    <div>
      <ul>
        <li :for={{name, answer} <- @contestants}>
          <.status_icon answered?={answer != nil} /> <%= name %>
        </li>
      </ul>
    </div>
    """
  end

  defp status_icon(%{wagered?: true} = assigns), do: ~H|<.icon name="hero-clock" />|
  defp status_icon(assigns), do: ~H|<.icon name="hero-check-circle" />|

  def handle_game_server_msg({:wager_submitted, {name, amount}}, socket) do
    {:ok, assign(socket, contestants: Map.put(socket.assigns.contestants, name, amount))}
  end
end
