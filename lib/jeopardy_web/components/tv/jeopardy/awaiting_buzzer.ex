defmodule JeopardyWeb.Components.TV.Jeopardy.AwaitingBuzzer do
  use JeopardyWeb.Components.Base, :tv
  require Logger
  alias Jeopardy.Games.{Game, Clue}
  alias Jeopardy.Repo
  import Ecto.Query

  @impl true
  def update(%{event: :timer_expired}, socket) do
    no_answer(
      socket.assigns.game,
      current_incorrect_answers(socket.assigns.players, socket.assigns.game.current_clue_id)
    )

    {:ok, socket}
  end

  @impl true
  def update(%{time_left: time_left}, socket), do: {:ok, assign(socket, timer: time_left)}

  @impl true
  def update(assigns, socket) do
    socket = assign(socket, assigns)

    num_incorrect_answers =
      current_incorrect_answers(socket.assigns.players, socket.assigns.game.current_clue_id)

    # start backup timer.  Hacky solution, but it works.
    Task.start(fn ->
      Process.sleep(5050)
      no_answer(socket.assigns.game, num_incorrect_answers)
    end)

    {:ok, socket}
  end

  defp current_incorrect_answers(players, clue_id) do
    players
    |> Enum.reduce(0, fn p, acc ->
      if clue_id in p.incorrect_answers,
        do: acc + 1,
        else: acc
    end)
  end

  defp no_answer(%Game{} = game, num_incorrect_answers) do
    q =
      from g in Game,
        join: c in Clue,
        on: g.current_clue_id == c.id,
        where: g.id == ^game.id,
        where: g.buzzer_lock_status == "clear",
        where: g.round_status == "awaiting_buzzer",
        where: g.current_clue_id == ^game.current_clue_id,
        where:
          fragment("coalesce(array_length(?, 1), 0)", c.incorrect_players) ==
            ^num_incorrect_answers

    updates = [buzzer_player: nil, buzzer_lock_status: "locked", round_status: "revealing_answer"]

    case Repo.update_all_ts(q, set: updates) do
      {0, _} ->
        false

      {1, _} ->
        Phoenix.PubSub.broadcast(
          Jeopardy.PubSub,
          game.code,
          {:round_status_change, "revealing_answer"}
        )
    end
  end
end
