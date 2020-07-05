defmodule JeopardyWeb.WagerComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML
  alias JeopardyWeb.WagerView
  alias Jeopardy.Games.{Wager, Player}
  require Logger

  def render(assigns) do
    WagerView.render("wager.html", assigns)
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)
    {min, max} = Player.min_max_wagers(socket.assigns.player, socket.assigns.clue)

    socket =
      socket
      |> assign(changeset: Wager.changeset(%Wager{}, %{}, min, max))
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
        Jeopardy.GameEngine.event(
          :wager,
          %{player_id: socket.assigns.player.id, amount: wager.amount},
          clue.game_id
        )

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
