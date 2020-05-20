defmodule JeopardyWeb.WagerComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML
  alias JeopardyWeb.WagerView
  alias Jeopardy.Games.{Wager, Player}
  require Logger
  import Jeopardy.FSM

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
    player = socket.assigns.player

    case Wager.validate(params, min, max) do
      {:ok, wager} ->
        data = %{clue: clue, player: player, wager: wager.amount}
        handle(:wager_submitted, data, socket.assigns.game_code)
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle(event, data, game_code) do
    game = Jeopardy.Games.get_by_code(game_code)
    module = module_from_game(game)
    module.handle(event, data, game)
  end
end
