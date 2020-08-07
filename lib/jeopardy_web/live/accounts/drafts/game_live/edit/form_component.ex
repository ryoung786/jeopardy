defmodule JeopardyWeb.Accounts.Drafts.GameLive.Edit.FormComponent do
  use JeopardyWeb, :live_component
  alias Jeopardy.Drafts

  @impl true
  def update(%{clue: clue} = assigns, socket) do
    changeset = Drafts.change_clue(%{}, clue)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"clue" => params}, socket) do
    changeset =
      socket.assigns.clue
      |> Drafts.change_clue(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"clue" => params}, socket) do
    %{game: game, clue: clue} = socket.assigns

    case Drafts.update_clue(game, clue, params) do
      {:ok, _game} ->
        {:noreply,
         socket
         |> put_flash(:info, "Clue updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
