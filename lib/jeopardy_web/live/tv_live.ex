defmodule JeopardyWeb.TvLive do
  use JeopardyWeb, :live_view

  def mount(params, _session, socket) do
    {:ok, game} = Jeopardy.GameServer.get_game(params["code"])

    if connected?(socket),
      do: Phoenix.PubSub.subscribe(Jeopardy.PubSub, "games:#{params["code"]}")

    {:ok,
     socket
     |> assign(code: params["code"])
     |> assign(players: game.players)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <ul>
        <li
          :for={player <- @players}
          id={"li-#{player}"}
          class="group flex"
          phx-remove={fade_away_left()}
        >
          <.modal id={"remove-modal-#{player}"}>
            <p class="mb-4">Are you sure you want to remove <%= player %> from the game?</p>
            <div class="flex justify-end gap-4">
              <button class="btn" phx-click={hide_modal("remove-modal-#{player}")}>
                Cancel
              </button>
              <button class="btn btn-error" phx-click={remove_player(player)}>Remove</button>
            </div>
          </.modal>
          <div
            class={[
              "flex w-full justify-between max-w-xs p-2 rounded",
              "group-hover:bg-slate-100 group-hover:cursor-pointer"
            ]}
            phx-click={show_modal("remove-modal-#{player}")}
          >
            <span><%= player %></span>
            <span class="text-red-700 bold cursor-pointer invisible group-hover:visible">
              ✗
            </span>
          </div>
        </li>
      </ul>
      <a :if={Enum.count(@players) >= 2} href="#" class="btn btn-primary">
        Start Game
      </a>
    </div>
    """
  end

  def handle_info({:player_added, name}, socket) do
    {:noreply, assign(socket, players: [name | socket.assigns.players])}
  end

  def handle_info({:player_removed, name}, socket) do
    {:noreply, assign(socket, players: List.delete(socket.assigns.players, name))}
  end

  def handle_info({:status_changed, _status}, socket) do
    {:noreply, socket}
  end

  def handle_event("remove_player", %{"player" => player}, socket) do
    case Jeopardy.GameServer.action(socket.assigns.code, :remove_player, player) do
      {:ok, game} -> {:noreply, assign(socket, players: game.players)}
      _ -> {:noreply, socket}
    end
  end

  defp remove_player(player) do
    JS.push("remove_player", value: %{player: player})
    |> hide_modal("remove-modal-#{player}")
  end

  defp fade_away_left(js \\ %JS{}) do
    JS.transition(
      js,
      {
        "transition-all transform ease-in duration-200",
        "motion-safe:-translate-x-10 opacity-0",
        "hidden"
      }
    )
  end
end
