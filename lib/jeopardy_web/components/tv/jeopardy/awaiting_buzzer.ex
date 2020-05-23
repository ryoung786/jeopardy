defmodule JeopardyWeb.Components.TV.Jeopardy.AwaitingBuzzer do
  use JeopardyWeb.Components.Base, :tv
  require Logger
  alias Jeopardy.Games.Game
  alias Jeopardy.Repo
  import Ecto.Query

  @impl true
  def update(%{event: :timer_expired}, socket) do
    no_answer(socket.assigns.game)
    {:ok, socket}
  end

  @impl true
  def update(%{time_left: time_left}, socket), do: {:ok, assign(socket, timer: time_left)}

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
