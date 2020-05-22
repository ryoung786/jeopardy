defmodule JeopardyWeb.Components.TV.Jeopardy.AwaitingBuzzer do
  use JeopardyWeb, :live_component
  require Logger
  alias Jeopardy.Games.Game
  alias Jeopardy.Repo
  import Ecto.Query

  @impl true
  def render(assigns), do: JeopardyWeb.TvView.render(tpl_path(assigns), assigns)

  @impl true
  def update(%{event: :timer_expired}, socket) do
    Logger.info("Awaiting Buzzer TV update timer expired socket: #{inspect(socket.assigns)}")
    no_answer(socket.assigns.game)
    {:ok, socket}
  end

  @impl true
  def update(%{event: :timer_start, time_left: time_left}, socket) do
    Logger.info("Awaiting Buzzer TV update timer start socket: #{inspect(socket.assigns)}")
    {:ok, assign(socket, timer: time_left)}
  end

  @impl true
  def update(%{event: :timer_tick, time_left: time_left}, socket) do
    Logger.info("Awaiting Buzzer TV update timer tick socket: #{inspect(socket.assigns)}")
    {:ok, assign(socket, timer: time_left)}
  end

  @impl true
  def update(assigns, socket), do: {:ok, assign(socket, assigns)}

  defp no_answer(%Game{} = game) do
    q =
      from g in Game,
        where: g.id == ^game.id,
        where: g.buzzer_lock_status == "clear",
        where: g.round_status == "awaiting_buzzer"

    updates = [buzzer_player: nil, buzzer_lock_status: "locked", round_status: "revealing_answer"]

    Repo.update_all_ts(q, set: updates)

    Phoenix.PubSub.broadcast(
      Jeopardy.PubSub,
      game.code,
      {:round_status_change, "awaiting_buzzer"}
    )
  end
end
