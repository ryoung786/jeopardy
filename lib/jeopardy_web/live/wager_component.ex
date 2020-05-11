defmodule JeopardyWeb.WagerComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML
  alias JeopardyWeb.WagerView
  alias Jeopardy.GameState
  alias Jeopardy.Games.{Wager, Player, Clue}
  alias Jeopardy.Repo
  require Logger

  def render(assigns) do
    {min, max} = Player.min_max_wagers(assigns.player, assigns.clue)
    assigns = assigns |> Map.put(:min, min) |> Map.put(:max, max)
    WagerView.render("wager.html", assigns)
  end

  def mount(_params, _session, socket) do
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
    {min, max} = Player.min_max_wagers(socket.assigns.player, socket.assigns.clue)
    changeset =
      %Wager{}
      |> Wager.changeset(params, min, max)
      |> Map.put(:action, :insert)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"wager" => params}, socket) do
    {min, max} = Player.min_max_wagers(socket.assigns.player, socket.assigns.clue)
    clue = socket.assigns.clue
    player = socket.assigns.player

    case Wager.validate(params, min, max) do
      {:ok, wager} ->
        if clue.round == "final_jeopardy" do
          Player.changeset(player, %{final_jeopardy_wager: wager.amount}) |> Repo.update()
          Phoenix.PubSub.broadcast(Jeopardy.PubSub, socket.assigns.game_code, :final_jeopardy_wager_submitted)
        else
          # store the wager amount in db
          Clue.changeset(clue, %{wager: wager.amount}) |> Repo.update()
          GameState.update_round_status(socket.assigns.game_code, "awaiting_daily_double_wager", "reading_daily_double")
        end
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
