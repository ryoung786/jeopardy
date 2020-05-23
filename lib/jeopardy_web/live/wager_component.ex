defmodule JeopardyWeb.WagerComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML
  alias JeopardyWeb.WagerView
  alias Jeopardy.Games.{Wager, Player, Clue, Game}
  alias Jeopardy.GameState
  alias Jeopardy.Repo
  import Ecto.Query
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
    player = socket.assigns.player

    case Wager.validate(params, min, max) do
      {:ok, wager} ->
        save_and_broadcast(player, clue, wager.amount, socket.assigns.game_code)
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

  defp save(clue, amount, game_code, :daily_double) do
    Clue.changeset(clue, %{wager: amount}) |> Repo.update()

    GameState.update_round_status(
      game_code,
      "awaiting_daily_double_wager",
      "reading_daily_double"
    )
  end

  defp save(player, amount, game, :final_jeopardy) do
    changeset = Player.changeset(player, %{final_jeopardy_wager: amount})

    with {:ok, player} <- Repo.update(changeset) do
      Phoenix.PubSub.broadcast(Jeopardy.PubSub, game.code, %{
        event: :final_jeopardy_wager,
        player: player
      })

      if all_final_jeopardy_wagers_submitted?(game) do
        # start clue timer
        GameState.update_round_status(game.code, "revealing_category", "reading_clue")
      end
    end
  end

  defp all_final_jeopardy_wagers_submitted?(%Game{} = game) do
    num_yet_to_submit =
      from(p in Player,
        select: count(1),
        where: p.game_id == ^game.id,
        where: p.name != ^game.trebek,
        where: is_nil(p.final_jeopardy_wager)
      )
      |> Repo.one()

    num_yet_to_submit == 0
  end
end
