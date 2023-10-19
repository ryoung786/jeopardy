defmodule JeopardyWeb.Components.Trebek.AwaitingFinalJeopardyWagers do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.WagerSubmitted
  alias Jeopardy.Timers

  @timer 30_000

  def assign_init(socket, game) do
    contestants =
      game.contestants |> Map.values() |> Map.new(&{&1.name, &1.final_jeopardy_wager})

    assign(socket,
      contestants: contestants,
      timer: @timer,
      time_remaining: Timers.time_remaining(game.fsm.data[:expires_at])
    )
  end

  def render(assigns) do
    ~H"""
    <div class="h-screen">
      <.instructions>
        <:additional>
          <div class="grid mb-8">
            <ul class="max-w-screen-sm place-self-center">
              <li :for={{name, wager} <- @contestants} class="flex items-center gap-2">
                <.status_icon wagered?={wager != nil} /> <%= name %>
              </li>
            </ul>
          </div>
        </:additional>
        Waiting for contestants to submit their wagers.
      </.instructions>
    </div>
    """
  end

  defp status_icon(%{wagered?: true} = assigns), do: ~H|<.icon name="hero-check-circle" />|
  defp status_icon(assigns), do: ~H|<.icon name="hero-clock" />|

  def handle_game_server_msg(%WagerSubmitted{name: name, amount: amount}, socket) do
    {:ok, assign(socket, contestants: Map.put(socket.assigns.contestants, name, amount))}
  end
end
