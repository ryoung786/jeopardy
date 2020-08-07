defmodule JeopardyWeb.Accounts.Drafts.GameLive.Edit.FinalJeopardy do
  use JeopardyWeb, :live_view
  alias Jeopardy.Drafts
  require Logger

  @impl true
  def handle_params(%{"id" => id}, _url, socket) do
    game = Drafts.get_game!(id)
    fj_clue = Map.get(game.clues, "final_jeopardy")

    {:noreply,
     socket
     |> assign(game: game)
     |> assign(fj_clue: fj_clue)
     |> assign(changeset: Drafts.change_final_jeopardy_clue(%{}, fj_clue))}
  end

  @impl true
  def handle_event("validate", %{"fj_clue" => params}, socket) do
    changeset =
      socket.assigns.fj_clue
      |> Drafts.change_final_jeopardy_clue(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"fj_clue" => params}, socket) do
    case Drafts.update_final_jeopardy_clue(socket.assigns.game, params) do
      {:ok, _game} ->
        {
          :noreply,
          socket
          |> put_flash(:info, "Game updated successfully")
          # |> push_redirect(to: socket.assigns.return_to)}
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
