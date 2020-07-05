defmodule JeopardyWeb.WagerComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML
  alias JeopardyWeb.WagerView
  alias Jeopardy.Games.{Wager, Player, Clue}
  alias Jeopardy.GameState
  alias Jeopardy.Repo
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
        Jeopardy.GameEngine.event(:wager, wager.amount, clue.game_id)

        # save_and_broadcast(player, clue, wager.amount, socket.assigns.game_code)
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_and_broadcast(%Player{} = player, clue, amount, game_code) do
    case clue.type do
      "daily_double" ->
        save(clue, amount, game_code, :daily_double)

      _ ->
        game = Jeopardy.Games.get_by_code(game_code)
        save(player, amount, game, :final_jeopardy)
    end
  end

  defp save(player, amount, game, :final_jeopardy) do
    changeset = Player.changeset(player, %{final_jeopardy_wager: amount})

    with {:ok, player} <- Repo.update(changeset) do
      Phoenix.PubSub.broadcast(Jeopardy.PubSub, game.code, %{
        event: :final_jeopardy_wager,
        player_wagered: player
      })
    end
  end
end
