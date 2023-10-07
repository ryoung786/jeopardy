defmodule JeopardyWeb.Components.Trebek.AwaitingFinalJeopardyWagers do
  use JeopardyWeb.FSMComponent
  alias Jeopardy.Timers

  def assign_init(socket, game) do
    contestants =
      game.contestants |> Map.values() |> Map.new(&{&1.name, &1.final_jeopardy_answer})

    assign(socket,
      contestants: contestants,
      time_remaining: Timers.time_remaining(game.fsm.data[:expires_at])
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <ul>
        <li :for={{name, wager} <- @contestants}>
          <.status_icon wagered?={wager != nil} /> <%= name %>
        </li>
      </ul>
      <.pie_timer time_remaining={@time_remaining} />
    </div>
    """
  end

  defp status_icon(%{wagered?: true} = assigns), do: ~H|<.icon name="hero-clock" />|
  defp status_icon(assigns), do: ~H|<.icon name="hero-check-circle" />|

  def handle_game_server_msg({:wager_submitted, {name, amount}}, socket) do
    {:ok, assign(socket, contestants: Map.put(socket.assigns.contestants, name, amount))}
  end
end
