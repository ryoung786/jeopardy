defmodule JeopardyWeb.WagerComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML
  alias JeopardyWeb.WagerView
  alias Jeopardy.GameState
  alias Jeopardy.Games.{Wager, Player, Clue}
  alias Jeopardy.Repo
  require Logger

  def render(assigns) do
    # {min, max} = Player.min_max_wagers(assigns.player, assigns.clue)
    # assigns = assigns |> Map.put(:min, min) |> Map.put(:max, max)
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
    # {min, max} = Player.min_max_wagers(socket.assigns.player, socket.assigns.clue)
    {min, max} = {socket.assigns.min, socket.assigns.max}
    changeset =
      %Wager{}
      |> Wager.changeset(params, min, max)
      |> Map.put(:action, :insert)
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"wager" => params}, socket) do
    # {min, max} = Player.min_max_wagers(socket.assigns.player, socket.assigns.clue)
    {min, max} = {socket.assigns.min, socket.assigns.max}
    clue = socket.assigns.clue
    player = socket.assigns.player

    case Wager.validate(params, min, max) do
      {:ok, wager} ->
        data = %{clue: clue, player: player, wager: wager.amount}
        handle(:wager_submitted, data, socket.assigns.game)
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle(event, data, game) do
    {a, b} = {Macro.camelize(game.status),
              Macro.camelize(game.round_status)}
    module = String.to_existing_atom("Elixir.Jeopardy.FSM.#{a}.#{b}")
    module.handle(event, data, game)
  end
end
