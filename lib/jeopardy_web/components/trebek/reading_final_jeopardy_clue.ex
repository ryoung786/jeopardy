defmodule JeopardyWeb.Components.Trebek.ReadingFinalJeopardyClue do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.GameServer
  alias Jeopardy.Timers

  @timer 60_000

  def assign_init(socket, game) do
    time_remaining = Timers.time_remaining(game.fsm.data[:expires_at])

    contestants =
      game.contestants |> Map.values() |> Map.new(&{&1.name, &1.final_jeopardy_answer})

    assign(socket,
      category: game.clue.category,
      clue: game.clue.clue,
      timer: @timer,
      time_remaining: time_remaining,
      contestants: contestants,
      finished_reading?: time_remaining != nil
    )
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

      <div :if={not @finished_reading?} class="grid grid-rows-[1fr_auto] min-h-screen">
        <.trebek_clue category={@game.clue.category} clue={@game.clue.clue} />
        <div class="p-4 grid">
          <.button class="btn-primary" phx-target={@myself} phx-click="finished-reading">
            Start Timer
          </.button>
        </div>
      </div>
    </div>
    """
  end

  defp status_icon(%{wagered?: true} = assigns), do: ~H|<.icon name="hero-check-circle" />|
  defp status_icon(assigns), do: ~H|<.icon name="hero-clock" />|

  def handle_event("finished-reading", _params, socket) do
    GameServer.action(socket.assigns.code, :timer_started)
    {:noreply, assign(socket, finished_reading?: true, time_remaining: @timer)}
  end
end
