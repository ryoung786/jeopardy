defmodule JeopardyWeb.Components.Trebek.AwaitingFinalJeopardyWagers do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    assign(socket,
      contestants: Map.new(game.contestants, &{&1.name, &1.final_jeopardy_wager}),
      time_left: DateTime.diff(game.fsm.data.expires_at, DateTime.utc_now(), :millisecond)
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
    </div>
    """
  end

  defp status_icon(%{wagered?: true} = assigns), do: ~H|<.icon name="hero-clock" />|
  defp status_icon(assigns), do: ~H|<.icon name="hero-check-circle" />|

  def handle_game_server_msg({:wager_submitted, {name, amount}}, socket) do
    {:ok, assign(socket, contestants: Map.put(socket.assigns.contestants, name, amount))}
  end
end
