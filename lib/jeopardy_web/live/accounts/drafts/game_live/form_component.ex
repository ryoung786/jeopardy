defmodule JeopardyWeb.Accounts.Drafts.GameLive.FormComponent do
  use JeopardyWeb, :live_component
  alias Jeopardy.Drafts

  @impl true
  def update(%{game: game} = assigns, socket) do
    changeset = Drafts.change_game(game)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"game" => game_params}, socket) do
    game_params =
      Map.update!(
        game_params,
        "tags",
        fn str -> String.split(str, ",", trim: true) |> Enum.map(&String.trim/1) end
      )

    changeset =
      socket.assigns.game
      |> Drafts.change_game(game_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"game" => game_params}, socket) do
    save_game(socket, socket.assigns.action, game_params)
  end

  defp save_game(socket, :edit, game_params) do
    case Drafts.update_game(socket.assigns.game, game_params) do
      {:ok, _game} ->
        {:noreply,
         socket
         |> put_flash(:info, "Game updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_game(socket, :new, game_params) do
    # owner is required.  We can get it from the pow authenticated current_user
    game_params =
      Map.merge(game_params, %{
        "owner_id" => socket.assigns.current_user.id,
        "owner_type" => "user"
      })

    case Drafts.create_game(game_params) do
      {:ok, game} ->
        {:noreply,
         socket
         |> put_flash(:info, "Game created successfully")
         |> push_redirect(to: Routes.game_edit_jeopardy_path(socket, :edit, game, "jeopardy"))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
