defmodule JeopardyWeb.Components.Tv.AwaitingPlayers do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  alias Jeopardy.FSM.Messages.PlayerAdded
  alias Jeopardy.FSM.Messages.PlayerRemoved
  alias Phoenix.LiveView.JS

  def assign_init(socket, game) do
    assign(socket, players: game.players)
  end

  def handle_game_server_msg(%PlayerRemoved{name: name}, socket) do
    {:ok, assign(socket, players: List.delete(socket.assigns.players, name))}
  end

  def handle_game_server_msg(%PlayerAdded{name: name}, socket) do
    {:ok, assign(socket, players: socket.assigns.players ++ [name])}
  end

  def render(assigns) do
    ~H"""
    <div>
      tv
      <ul>
        <li
          :for={player <- Enum.sort(@players)}
          id={"li-#{player}"}
          class="group flex"
          phx-remove={fade_away_left()}
        >
          <.modal id={"remove-modal-#{player}"}>
            <p class="mb-4">Are you sure you want to remove <%= player %> from the game?</p>
            <div class="flex justify-end gap-4">
              <button
                class="btn"
                phx-click={hide_modal("remove-modal-#{player}")}
                phx-target={@myself}
              >
                Cancel
              </button>
              <button class="btn btn-error" phx-click={remove_player(player)} phx-target={@myself}>
                Remove
              </button>
            </div>
          </.modal>
          <div
            class={[
              "flex w-full justify-between max-w-xs p-2 rounded",
              "group-hover:bg-slate-100 group-hover:cursor-pointer"
            ]}
            phx-click={show_modal("remove-modal-#{player}")}
            phx-target={@myself}
          >
            <span><%= player %></span>
            <span class="text-red-700 bold cursor-pointer invisible group-hover:visible">
              ✗
            </span>
          </div>
        </li>
      </ul>
      <button
        :if={Enum.count(@players) >= 2}
        class="btn btn-primary"
        phx-click="start_game"
        phx-target={@myself}
      >
        Start Game
      </button>
    </div>
    """
  end

  def handle_event("remove_player", %{"player" => player}, socket) do
    case Jeopardy.GameServer.action(socket.assigns.code, :remove_player, player) do
      {:ok, game} -> {:noreply, assign(socket, players: game.players)}
      _ -> {:noreply, socket}
    end
  end

  def handle_event("start_game", _, socket) do
    Jeopardy.GameServer.action(socket.assigns.code, :continue)
    {:noreply, socket}
  end

  # JS interactions

  defp remove_player(name) do
    "remove_player"
    |> JS.push(value: %{player: name})
    |> hide_modal("remove-modal-#{name}")
  end
end
