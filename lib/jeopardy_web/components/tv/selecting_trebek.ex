defmodule JeopardyWeb.Components.Tv.SelectingTrebek do
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    assign(socket, players: game.players)
  end

  def render(assigns) do
    ~H"""
    <div>
      <h1>Please select a player to host</h1>
      <ul>
        <li :for={player <- Enum.sort(@players)} id={"li-#{player}"} class="group flex">
          <.modal id={"elect-modal-#{player}"}>
            <p class="mb-4">Are you sure you want to make <%= player %> the host?</p>
            <div class="flex justify-end gap-4">
              <button
                class="btn"
                phx-click={hide_modal("remove-modal-#{player}")}
                phx-target={@myself}
              >
                Cancel
              </button>
              <button class="btn btn-primary" phx-click={elect_host(player)} phx-target={@myself}>
                Yes
              </button>
            </div>
          </.modal>
          <div
            class={[
              "flex w-full justify-between max-w-xs p-2 rounded",
              "group-hover:bg-slate-100 group-hover:cursor-pointer"
            ]}
            phx-click={show_modal("elect-modal-#{player}")}
            phx-target={@myself}
          >
            <span><%= player %></span>
          </div>
        </li>
      </ul>
    </div>
    """
  end

  def handle_event("elect_host", %{"player" => player}, socket) do
    case Jeopardy.GameServer.action(socket.assigns.code, :select_trebek, player) do
      {:ok, game} -> {:noreply, assign(socket, players: game.players)}
      _ -> {:noreply, socket}
    end
  end

  # JS interactions

  defp elect_host(name) do
    JS.push("elect_host", value: %{player: name})
    |> hide_modal("remove-modal-#{name}")
  end
end
