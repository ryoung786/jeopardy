defmodule JeopardyWeb.WagerComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML
  alias JeopardyWeb.WagerView
  alias Jeopardy.Games.{Wager, Player, Clue}
  alias Jeopardy.GameState
  require Logger

  def render(assigns) do
    WagerView.render("wager.html", assigns)
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)
    {min, max} = Player.min_max_wagers(socket.assigns.player, socket.assigns.clue)

    cs = Wager.changeset(%Wager{}, %{}, min, max)

    socket =
      socket
      |> assign(socket, changeset: cs)
      |> assign(min: min)
      |> assign(max: max)

    {:ok, socket}
  end

  def handle_event("validate", %{"wager" => params}, socket) do
    {min, max} = {socket.assigns.min, socket.assigns.max}

    changeset =
      %Wager{}
      |> Wager.changeset(params, min, max)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"wager" => params}, socket) do
    {min, max} = {socket.assigns.min, socket.assigns.max}
    clue = socket.assigns.clue

    case Wager.validate(params, min, max) do
      {:ok, wager} ->
        save_and_broadcast(clue, wager.amount, socket.assigns.game_code)
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_and_broadcast(clue, amount, game_code) do
    Clue.changeset(clue, %{wager: amount}) |> Jeopardy.Repo.update()

    GameState.update_round_status(
      game_code,
      "awaiting_daily_double_wager",
      "reading_daily_double"
    )
  end
end
