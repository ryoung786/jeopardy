defmodule JeopardyWeb.WagerComponent do
  use Phoenix.LiveComponent
  use Phoenix.HTML
  alias JeopardyWeb.WagerView
  alias Jeopardy.Games.{Wager, Clue}
  require Logger

  def render(assigns) do
    WagerView.render("wager.html", assigns)
  end

  def mount(_params, _session, socket) do
    min = socket.assigns.min
    max = socket.assigns.max

    cs = Wager.changeset(%Wager{}, %{}, min, max)
    socket = assign(socket, changeset: cs)
    # {:ok, socket}
    {:noreply, socket}
  end

  def handle_event("validate", %{"wager" => params}, socket) do
    min = socket.assigns.min
    max = socket.assigns.max
    # changeset =
    #   %Wager{}
    #   |> Wager.changeset(params, 5,100)
    # |> Map.put(:action, :insert)
    {_, changeset} = Wager.validate(params, min, max)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("save", %{"wager" => params}, socket) do
    min = socket.assigns.min
    max = socket.assigns.max
    clue = socket.assigns.clue

    case Wager.validate(params, min, max) do
      {:ok, wager} ->
        # store the wager amount in db
        Clue.changeset(clue, %{wager: wager.amount}) |> Repo.update()
        GameState.update_round_status(socket.assigns.game_code, "awaiting_daily_double_wager", "reading_daily_double")
        {:noreply, socket}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
# defmodule JeopardyWeb.WagerComponent do
#   use JeopardyWeb, :live_component
#   alias JeopardyWeb.WagerView
#   alias Jeopardy.Games.{Wager, Clue}
#   require Logger

#   def mount(_params, _session, socket) do
#     min = socket.assigns.min
#     max = socket.assigns.max

#     {:ok, assign(socket, %{changeset: Wager.changeset(%Wager{}, [], min, max)})}
#   end

#   def render(assigns) do
#     WagerView.render("wager.html", assigns)
#   end

#   def handle_event("validate", %{"wager" => params}, socket) do
#     Logger.info("XXXXXXXXXXXXXXXXXXXXXXX")
#     min = socket.assigns.min
#     max = socket.assigns.max
#     changeset =
#       %Wager{}
#       |> Wager.changeset(params, min, max)
#       |> Map.put(:action, :insert)

#     {:noreply, assign(socket, changeset: changeset)}
#   end

#   def handle_event("save", %{"wager" => params}, socket) do
#     min = socket.assigns.min
#     max = socket.assigns.max
#     clue = socket.assigns.clue

#     case Wager.validate(params, min, max) do
#       {:ok, wager} ->
#         # store the wager amount in db
#         Clue.changeset(clue, %{wager: wager.amount}) |> Repo.update()
#         GameState.update_round_status(socket.assigns.game_code, "awaiting_daily_double_wager", "reading_daily_double")
#         {:noreply, socket}
#       {:error, %Ecto.Changeset{} = changeset} ->
#         {:noreply, assign(socket, changeset: changeset)}
#     end
#   end
# end
