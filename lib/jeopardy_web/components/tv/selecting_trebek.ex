defmodule JeopardyWeb.Components.Tv.SelectingTrebek do
  @moduledoc false
  use JeopardyWeb.FSMComponent

  def assign_init(socket, game) do
    assign(socket, players: game.players)
  end

  def handle_event("elect_host", %{"player" => player}, socket) do
    case Jeopardy.GameServer.action(socket.assigns.code, :select_trebek, player) do
      {:ok, game} -> {:noreply, assign(socket, players: game.players)}
      _ -> {:noreply, socket}
    end
  end

  # JS interactions

  defp elect_host(name) do
    "elect_host"
    |> JS.push(value: %{player: name})
    |> hide_modal("remove-modal-#{name}")
  end
end
