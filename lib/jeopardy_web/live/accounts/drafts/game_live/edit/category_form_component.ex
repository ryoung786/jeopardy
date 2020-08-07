defmodule JeopardyWeb.Accounts.Drafts.GameLive.Edit.CategoryFormComponent do
  use JeopardyWeb, :live_component
  alias Jeopardy.Drafts
  require Logger

  @impl true
  def update(%{category: category} = assigns, socket) do
    changeset = Drafts.change_category(%{}, category)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"category" => params}, socket) do
    changeset =
      socket.assigns.category
      |> Drafts.change_category(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"category" => params}, socket) do
    %{game: game, category: category, idx: idx} = socket.assigns

    idx = String.to_integer(idx)

    case Drafts.update_category(game, idx, category, params) do
      {:ok, _category} ->
        {:noreply,
         socket
         |> put_flash(:info, "Category updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
